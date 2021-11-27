//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";

contract TokenManagement is Ownable {
    Token public token;

    uint256 public constant TOKENSPERBNB = 100;
    uint256 public constant TOTAL_SUPPLY = 1000000000000;
    uint128 public constant TREASURY_BP = 2;
    uint128 public constant REWARD_BP = 1;
    uint128 public constant LIQUIDITY_BP = 2;
    uint256 public currentAmount = 0;
    uint256 public constant maximumAmountOfTreasury = 10000000000;
    uint256 public treasuryWallet = 0;
    uint256 public rewardDistribution = 0;
    uint256 public liquidity = 0;
    address public treasuryAddress1;
    address public treasuryAddress2;

    uint256 public launchDay;

    event BuyTokens(address buyer, uint256 amountOfBNB, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfTokens,
        uint256 amountOfBNB
    );

    constructor(
        address _tokenAddress,
        address _treasuryAddress1,
        address _treasuryAddress2
    ) {
        token = Token(_tokenAddress);
        treasuryAddress1 = _treasuryAddress1;
        treasuryAddress2 = _treasuryAddress2;
        launchDay = block.timestamp;
    }

    function buy() public payable returns (uint256) {
        require(msg.value > 0, "Send BNB to buy some tokens");

        uint256 amountToBuy = msg.value * TOKENSPERBNB;

        uint256 tokenManagementBalance = token.balanceOf(address(this));
        require(tokenManagementBalance >= amountToBuy, "Not have enough token");

        if (
            treasuryWallet + (amountToBuy * TREASURY_BP) / 100 <
            maximumAmountOfTreasury
        ) {
            treasuryWallet += (amountToBuy * TREASURY_BP) / 100;
        }

        rewardDistribution += (amountToBuy * LIQUIDITY_BP) / 100;
        liquidity += (amountToBuy * LIQUIDITY_BP) / 1000;

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

        treasuryWallet -= (_tokenAmountToSell * TREASURY_BP) / 100;
        rewardDistribution -= (_tokenAmountToSell * REWARD_BP) / 100;
        liquidity -= (_tokenAmountToSell * LIQUIDITY_BP) / 100;

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

    function widthdrawByTreasury(uint256 _amount) public {
        require(
            msg.sender == treasuryAddress1 || msg.sender == treasuryAddress2,
            "Can not widthraw"
        );

        if (launchDay - block.timestamp <= 30 days) {
            require(
                _amount <= (treasuryWallet * 5) / 100,
                "Can not withdraw more than 5%"
            );
            bool sent = token.transferFrom(msg.sender, address(this), _amount);
            require(sent, "Failed to transfer tokens");
        } else {
            require(
                _amount <= (treasuryWallet * 1) / 100,
                "Can not withdraw more than 1%"
            );
            bool sent = token.transferFrom(msg.sender, address(this), _amount);
            require(sent, "Failed to transfer tokens");
        }
    }
}
