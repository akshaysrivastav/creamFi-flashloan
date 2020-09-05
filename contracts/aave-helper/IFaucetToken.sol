pragma solidity ^0.5.0;

import "../IERC20.sol";

contract IFaucetToken is IERC20 {
    function mint(uint256 value) public returns (bool);
}