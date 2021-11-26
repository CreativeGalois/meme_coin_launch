//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    string public constant NAME = "Meme";
    string public constant SYMBOL = "MEME";
    uint256 public constant TOTAL_SUPPLY = 1000000000000;

    constructor() ERC20(NAME, SYMBOL) {
        _mint(address(this), TOTAL_SUPPLY);
    }
}
