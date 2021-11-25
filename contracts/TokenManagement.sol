//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Token.sol";

contract TokenManagement {
    Token public token;

    uint256 public constant TOKENSPERBNB = 100;
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

    event BuyTokens(address buyer, uint256 amountOfBNB, uint256 amountOfTokens);

    constructor(
        address _tokenAddress,
        address _owner,
        address _treasuryAddress1,
        address _treasuryAddress2
    ) {
        Token(_tokenAddress);
        owner = _owner;
        treasuryAddress1 = _treasuryAddress1;
        treasuryAddress2 = _treasuryAddress2;
    }

    function buy() public payable returns (uint256 tokenAmount) {
        // uint256 currentSupply = token.totalSupply();
        // require(currentSupply + _amount < TOTAL_SUPPLY, "Can not buy token");
        // treasuryWallet += (_amount * TREASURY_BP) / 1000;
        // rewardDistribution += (_amount * REWARD_BP) / 1000;
        // liquidity += (_amount * LIQUIDITY_BP) / 1000;
        // _mint(msg.sender, _amount);
        require(msg.value > 0, "Send BNB to buy some tokens");

        uint256 amountToBuy = msg.value * TOKENSPERBNB;

        uint256 tokenManagementBalance = token.balanceOf(address(this));
        require(tokenManagementBalance >= amountToBuy, "Not have enough token");

        bool sent = token.transfer(msg.sender, amountToBuy);
        require(sent, "Failed to transfer token to user");

        emit BuyTokens(msg.sender, msg.value, amountToBuy);

        return amountToBuy;
    }

    function sell(uint256 _amount) public {}
}
