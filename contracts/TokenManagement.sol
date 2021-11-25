//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";

contract TokenManagement {

    Token public token;

    uint256 public constant TOTAL_SUPPLY = 1000000000000;
    uint128 public constant TREASURY_BP = 200;
    uint128 public constant REWARD_BP = 100;
    uint128 public constant LIQUIDITY_BP = 200;
    uint256 public currentAmount = 0;
    uint256 private treasuryWallet = 0;
    uint256 private rewardDistribution = 0;
    uint256 private liquidity = 0;
    address private owner;
    address public treasuryAddress1;
    address public treasuryAddress2;

    constructor(
        address _owner,
        address _treasuryAddress1,
        address _treasuryAddress2
    ) {
        owner = _owner;
        treasuryAddress1 = _treasuryAddress1;
        treasuryAddress2 = _treasuryAddress2;
    }

    function buy(uint256 _amount) public {
        uint256 currentSupply = token.totalSupply();
        require(currentSupply + _amount < TOTAL_SUPPLY, "Can not buy token");
        treasuryWallet += (_amount * TREASURY_BP) / 1000;
        rewardDistribution += (_amount * REWARD_BP) / 1000;
        liquidity += (_amount * LIQUIDITY_BP) / 1000;
        _mint(msg.sender, _amount);
    }

    function sell(uint256 _amount) public {}
}
