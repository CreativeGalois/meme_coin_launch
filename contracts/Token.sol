//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    string public constant NAME = "Meme";
    string public constant SYMBOL = "MEME";
    uint256 public constant TOTAL_SUPPLY = 1000000000000;
    address private owner;
    address public treasuryAddress1;
    address public treasuryAddress2;

    constructor(
        address _owner,
        address _treasuryAddress1,
        address _treasuryAddress2
    ) ERC20(NAME, SYMBOL) {
        owner = _owner;
        treasuryAddress1 = _treasuryAddress1;
        treasuryAddress2 = _treasuryAddress2;
    }
}
