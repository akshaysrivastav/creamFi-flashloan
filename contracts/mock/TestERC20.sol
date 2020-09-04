
pragma solidity 0.5.16;

import "../ERC20.sol";
import "../ERC20Detailed.sol";

/**
 * @dev Extension of `ERC20`
 */
contract TestERC20 is ERC20, ERC20Detailed {

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) ERC20Detailed(name, symbol, decimals) public {
    }

    /**
     * @dev See `ERC20._mint`.
     */
    function mint(address account, uint256 amount) public returns (bool) {
        _mint(account, amount);
        return true;
    }

    /**
     * @dev Destoys `amount` tokens from the caller.
     *
     * See `ERC20._burn`.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @dev See `ERC20._burnFrom`.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}