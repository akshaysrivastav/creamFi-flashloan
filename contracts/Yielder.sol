pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./ContractWithFlashLoan.sol";

contract Yielder is ContractWithFlashLoan, Ownable {
    using SafeMath for uint256;
    
    event Logger(uint256 value);

    constructor(address _aaveLPProvider)
        public payable
        ContractWithFlashLoan(_aaveLPProvider)
    {}

    function start(address loanToken, uint256 flashLoanAmount) public payable {
        initateFlashLoan(address(this), loanToken, flashLoanAmount, "");
    }

    function afterLoanSteps(
        address loanedToken,
        uint256 amount,
        uint256 fees,
        bytes memory params
    ) internal {
        logTokenBalance(true, address(0));
        emit Logger(amount);
        emit Logger(fees);

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

    function tokenBalance(address token) public view returns (uint balance) {
        return IERC20(token).balanceOf(address(this));
    }

    function ethBalance() public view returns (uint balance) {
        return address(this).balance;
    }

    // for testing
    function logTokenBalance(bool isEth, address tokenAddress) public returns (uint256) {
        uint256 balOfThis;
        if (isEth) {
            balOfThis = address(this).balance;
        } else {
            balOfThis = IERC20(tokenAddress).balanceOf(address(this));
        }        
        emit Logger(balOfThis);
        return balOfThis;
    }
}
