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
    event SellTokens(
        address seller,
        uint256 amountOfTokens,
        uint256 amountOfBNB
    );

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

    function buy() public payable returns (uint256) {
        require(msg.value > 0, "Send BNB to buy some tokens");

        uint256 amountToBuy = msg.value * TOKENSPERBNB;

        uint256 tokenManagementBalance = token.balanceOf(address(this));
        require(tokenManagementBalance >= amountToBuy, "Not have enough token");

        bool sent = token.transfer(msg.sender, amountToBuy);
        require(sent, "Failed to transfer token to user");

        emit BuyTokens(msg.sender, msg.value, amountToBuy);

        return amountToBuy;
    }

    function sell(uint256 _tokenAmountToSell) public {
        require(_tokenAmountToSell > 0, "Greater than zero");

        uint256 userBalance = token.balanceOf(msg.sender);
        require(userBalance >= _tokenAmountToSell, "Your balance is lower");

        uint256 amountOfBNBToTransfer = _tokenAmountToSell / TOKENSPERBNB;
        uint256 ownerBNBBalance = address(this).balance;
        require(
            ownerBNBBalance >= amountOfBNBToTransfer,
            "Not have enough funds"
        );

        bool sent = token.transferFrom(
            msg.sender,
            address(this),
            _tokenAmountToSell
        );
        require(sent, "Failed to transfer tokens");

        (sent, ) = msg.sender.call{value: amountOfBNBToTransfer}("");
        require(sent, "Failed to send BNB to the user");

        emit SellTokens(msg.sender, _tokenAmountToSell, amountOfBNBToTransfer);
    }
}
