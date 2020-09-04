pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./DydxFlashloaner.sol";
import "./bZxFlashLoaner.sol";
import "./Ownable.sol";
import "./IBZx.sol";

contract Liquidator is DydxFlashloaner, bZxFlashLoaner, Ownable {
    event Logger(uint256 value);

    uint8 public soloFees = 2 wei;
    uint256 public bZxFeePercentage = 5e16; // 0.05%

    struct CallData {
        address bZxAddress;
        bytes32 loanId;
        address receiver;
        address collateralToken;
        uint256 flashLoanAmount;
        uint256 iniCollateralTokenBal;
    }

    CallData _callData;

    struct CallDataBzx {
        uint256 iniCollateralTokenBal;
        uint256 loanTokenRepayAmount;
    }

    CallDataBzx _callDataBzx;

    function startWithDyDx(
        address dydxSolo,
        address loanToken,
        address collateralToken,
        address bZxAddress,
        bytes32 loanId,
        address receiver,
        uint256 flashLoanAmount
    ) public payable {
        if (IERC20(loanToken).balanceOf(address(this)) < soloFees) {
            IERC20(loanToken).transferFrom(msg.sender, address(this), soloFees);
        }

        _callData = CallData({
            bZxAddress: bZxAddress,
            loanId: loanId,
            receiver: receiver,
            collateralToken: collateralToken,
            flashLoanAmount: flashLoanAmount,
            iniCollateralTokenBal: IERC20(collateralToken).balanceOf(receiver)
        });
        initateFlashLoan(dydxSolo, loanToken, flashLoanAmount);
    }

    function afterLoanSteps(address loanedTokenAddress, uint256 repayAmount)
        internal
    {
        address bZxAddress = _callData.bZxAddress;
        if (
            IERC20(loanedTokenAddress).allowance(address(this), bZxAddress) <
            _callData.flashLoanAmount
        ) {
            IERC20(loanedTokenAddress).approve(
                bZxAddress,
                _callData.flashLoanAmount
            );
        }

        liquidateBzxLoan(
            _callData.bZxAddress,
            _callData.loanId,
            _callData.receiver,
            _callData.flashLoanAmount
        );

        uint256 finalCollateralTokenBal = IERC20(_callData.collateralToken)
            .balanceOf(_callData.receiver);
        require(
            finalCollateralTokenBal >= _callData.iniCollateralTokenBal,
            "Liquidation not profitable"
        );

        uint256 finalLoanTokenBal = IERC20(loanedTokenAddress).balanceOf(
            address(this)
        );
        if (finalLoanTokenBal < repayAmount) {
            // swap collateral token with loan token
            uint256 collateralTokenProfit = finalCollateralTokenBal.sub(
                _callData.iniCollateralTokenBal
            );
            uint256 requiredLoanTokenAmount = repayAmount.sub(
                finalLoanTokenBal
            );

            if (
                IERC20(_callData.collateralToken).allowance(
                    address(this),
                    bZxAddress
                ) < collateralTokenProfit
            ) {
                IERC20(_callData.collateralToken).approve(
                    bZxAddress,
                    collateralTokenProfit
                );
            }
            IBZx(bZxAddress).swapExternal(
                _callData.collateralToken,
                loanedTokenAddress,
                address(this),
                address(this),
                collateralTokenProfit,
                requiredLoanTokenAmount,
                ""
            );
        }
    }

    function startWithBzx(
        address iToken,
        address loanToken,
        address collateralToken,
        address bZxAddress,
        bytes32 loanId,
        address receiver,
        uint256 flashLoanAmount
    ) public payable {
        uint256 flashLoanFee = flashLoanAmount.mul(bZxFeePercentage).div(1e20);
        uint256 repayAmount = flashLoanAmount.add(flashLoanFee);

        // if (IERC20(loanToken).balanceOf(address(this)) < repayAmount) {
        //     IERC20(loanToken).transferFrom(
        //         msg.sender,
        //         address(this),
        //         flashLoanFee + 1
        //     );
        // }

        _callDataBzx = CallDataBzx({
            iniCollateralTokenBal: IERC20(collateralToken).balanceOf(
                address(this)
            ),
            loanTokenRepayAmount: repayAmount
        });
        initiateFlashLoanBzx(
            iToken,
            loanToken,
            collateralToken,
            bZxAddress,
            loanId,
            receiver,
            flashLoanAmount
        );
    }

    function afterLoanStepsBzx(
        address iToken,
        address loanToken,
        address collateralToken,
        address bZxAddress,
        bytes32 loanId,
        address receiver,
        uint256 flashLoanAmount
    ) public {
        receiver;    // shh
        if (
            IERC20(loanToken).allowance(address(this), bZxAddress) <
            flashLoanAmount
        ) {
            IERC20(loanToken).approve(bZxAddress, flashLoanAmount);
        }
        liquidateBzxLoan(bZxAddress, loanId, address(this), flashLoanAmount);

        uint256 finalCollateralTokenBal = IERC20(collateralToken).balanceOf(
            address(this)
        );
        require(
            finalCollateralTokenBal > _callDataBzx.iniCollateralTokenBal,
            "Liquidation not profitable"
        );

        uint256 finalLoanTokenBal = IERC20(loanToken).balanceOf(address(this));
        if (finalLoanTokenBal < _callDataBzx.loanTokenRepayAmount) {
            // swap collateral token with loan token
            uint256 collateralTokenProfit = finalCollateralTokenBal.sub(
                _callDataBzx.iniCollateralTokenBal
            );
            uint256 requiredLoanTokenAmount = _callDataBzx
                .loanTokenRepayAmount
                .sub(finalLoanTokenBal);

            if (
                IERC20(collateralToken).allowance(address(this), bZxAddress) <
                collateralTokenProfit
            ) {
                IERC20(collateralToken).approve(
                    bZxAddress,
                    collateralTokenProfit
                );
            }
            IBZx(bZxAddress).swapExternal(
                collateralToken,
                loanToken,
                address(this),
                address(this),
                collateralTokenProfit,
                requiredLoanTokenAmount,
                ""
            );
        }

        repayFlashLoanBzx(loanToken, iToken, _callDataBzx.loanTokenRepayAmount);
    }

    // closeAmount is denominated in loanToken
    function liquidateBzxLoan(
        address bzx,
        bytes32 loanId,
        address receiver,
        uint256 closeAmount
    ) internal {
        (, uint256 seizedAmount, ) = IBZx(bzx).liquidate(
            loanId,
            receiver,
            closeAmount
        );
        require(seizedAmount != 0, "BZX Liquidation Failed");
    }

    // for testing
    function logTokenBalance(address tokenAddress) public returns (uint256) {
        uint256 balOfThis = IERC20(tokenAddress).balanceOf(address(this));
        emit Logger(balOfThis);
        return balOfThis;
    }

    function getWeth(address weth, uint256 amount) internal {
        Weth(weth).deposit.value(amount)();
    }

    function transferEth(uint256 amount)
        public
        onlyOwner
        returns (bool success)
    {
        return transferEthInternal(amount);
    }

    function transferEthInternal(uint256 amount)
        internal
        returns (bool success)
    {
        address(uint160(owner())).transfer(amount);
        return true;
    }

    function transferToken(address token, uint256 amount)
        public
        onlyOwner
        returns (bool success)
    {
        return transferTokenInternal(token, amount);
    }

    function transferTokenInternal(address token, uint256 amount)
        internal
        returns (bool success)
    {
        IERC20(token).transfer(owner(), amount);
        return true;
    }
}

contract Weth {
    function deposit() public payable {}
}
