pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";

contract bZxFlashLoaner {
    function initiateFlashLoanBzx(
        address iToken,
        address loanToken,
        address collateralToken,
        address bZxAddress,
        bytes32 loanId,
        address receiver,
        uint256 flashLoanAmount
    ) internal {
        BzxITokenInterface iTokenContract = BzxITokenInterface(iToken);
        iTokenContract.flashBorrow(
            flashLoanAmount,
            address(this),
            address(this),
            "",
            abi.encodeWithSignature(
                "afterLoanStepsBzx(address,address,address,address,bytes32,address,uint256)",
                iToken,
                loanToken,
                collateralToken,
                bZxAddress,
                loanId,
                receiver,
                flashLoanAmount
            )
        );
    }

    function repayFlashLoanBzx(
        address loanToken,
        address iToken,
        uint256 loanAmount
    ) internal {
        IERC20(loanToken).transfer(iToken, loanAmount);
    }

    function afterLoanStepsBzx(
        address iToken,
        address loanToken,
        address collateralToken,
        address bZxAddress,
        bytes32 loanId,
        address receiver,
        uint256 flashLoanAmount
    ) public {}
}

contract BzxITokenInterface {
    function flashBorrow(
        uint256 borrowAmount,
        address borrower,
        address target,
        string calldata signature,
        bytes calldata data
    ) external payable returns (bytes memory) {}
}
