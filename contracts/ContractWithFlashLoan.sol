pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./aave-helper/ILendingPool.sol";
import "./aave-helper/IFlashLoanReceiver.sol";
import "./aave-helper/FlashloanReceiverBase.sol";

import "./IERC20.sol";

contract ContractWithFlashLoan is FlashLoanReceiverBase {
    address AaveLendingPoolAddressProviderAddress;

    constructor(address _provider) internal FlashLoanReceiverBase(_provider) {
        AaveLendingPoolAddressProviderAddress = _provider;
    }

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    ) external {
        afterLoanSteps(_reserve, _amount, _fee, _params);

        transferFundsBackToPoolInternal(_reserve, _amount.add(_fee));
    }

    // Entry point
    function initateFlashLoan(
        address contractWithFlashLoan,
        address assetToFlashLoan,
        uint256 amountToLoan,
        bytes memory _params
    ) internal {
        // Get Aave lending pool
        ILendingPool lendingPool = ILendingPool(
            ILendingPoolAddressesProvider(AaveLendingPoolAddressProviderAddress)
                .getLendingPool()
        );

        // Ask for a flashloan
        // LendingPool will now execute the `executeOperation` function above
        lendingPool.flashLoan(
            contractWithFlashLoan, // Which address to callback into, alternatively: address(this)
            assetToFlashLoan,
            amountToLoan,
            _params
        );
    }

    function afterLoanSteps(
        address,
        uint256,
        uint256,
        bytes memory
    ) internal {}
}
