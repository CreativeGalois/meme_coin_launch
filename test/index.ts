import { expect, use } from "chai";
import { ethers } from "hardhat";
import { solidity } from "ethereum-waffle";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

use(solidity);

describe("Token Management", function () {
  let owner: SignerWithAddress;
  let treasury1: SignerWithAddress;
  let treasury2: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addrs;
  const TOTAL_SUPPLY = 1000000000000;

  let tokenManagementContract: any;
  let tokenFactory;
  let tokenContract: any;

  let tokenMangementSupply: any;
  let tokensPerBnb: number;

  beforeEach(async () => {
    [owner, treasury1, treasury2, addr1, ...addrs] = await ethers.getSigners();

    tokenFactory = await ethers.getContractFactory("Token");
    tokenContract = await tokenFactory.deploy();

    const TokenManagementContract = await ethers.getContractFactory(
      "TokenManagement"
    );
    tokenManagementContract = await TokenManagementContract.deploy(
      tokenContract.address,
      owner.address,
      treasury1.address,
      treasury2.address
    );

    await tokenContract.transfer(
      tokenManagementContract.address,
      ethers.utils.parseEther("1000")
    );

    tokenMangementSupply = await tokenContract.balanceOf(
      tokenManagementContract.address
    );
    tokensPerBnb = await tokenManagementContract.TOKENSPERBNB();
  });

  describe("Test buy() method", () => {
    it("buy reverted no eth sent", async () => {
      const amount = ethers.utils.parseEther("0");
      await expect(
        tokenManagementContract.connect(addr1).buy({ value: amount })
      ).to.be.revertedWith("Send BNB to buy some tokens");
    });

    it("buy reverted tokenmanagement does not have enough tokens", async () => {
      const amount = ethers.utils.parseEther("101");
      await expect(
        tokenManagementContract.connect(addr1).buy({ value: amount })
      ).to.be.revertedWith("Not have enough token");
    });

    it("buy sucess", async () => {
      const amount = ethers.utils.parseEther("1");

      await expect(
        tokenManagementContract.connect(addr1).buy({ value: amount })
      )
        .to.emit(tokenManagementContract, "BuyTokens")
        .withArgs(addr1.address, amount, amount.mul(tokensPerBnb));

      const userTokenBalance = await tokenContract.balanceOf(addr1.address);
      const userTokenAmount = ethers.utils.parseEther("100");
      expect(userTokenBalance).to.equal(userTokenAmount);

      const tokenManagementTokenBalance = await tokenContract.balanceOf(
        tokenManagementContract.address
      );
      expect(tokenManagementTokenBalance).to.equal(
        tokenMangementSupply.sub(userTokenAmount)
      );

      const tokenManagementBalance = await ethers.provider.getBalance(
        tokenManagementContract.address
      );
      expect(tokenManagementBalance).to.equal(amount);
    });
  });

  describe("Test sell() method", async () => {
    it("sellTokens reverted because tokenAmountToSell is 0", async () => {
      const amountToSell = ethers.utils.parseEther("0");
      await expect(
        tokenManagementContract.connect(addr1).sell(amountToSell)
      ).to.be.revertedWith("Greater than zero");
    });

    it("sell reverted because user has not enough tokens", async () => {
      const amountToSell = ethers.utils.parseEther("1");
      await expect(
        tokenManagementContract.connect(addr1).sell(amountToSell)
      ).to.be.revertedWith("Your balance is lower");
    });

    it("sell reverted because user has now approved transfer", async () => {
      const bnbOfTokenToBuy = ethers.utils.parseEther("1");

      await tokenManagementContract.connect(addr1).buy({
        value: bnbOfTokenToBuy,
      });

      const amountToSell = ethers.utils.parseEther("100");
      await expect(
        tokenManagementContract.connect(addr1).sell(amountToSell.toBigInt())
      ).to.be.revertedWith("ERC20: transfer amount exceeds allowance");
    });

    it("sell sucess", async () => {
      const bnbOfTokenToBuy = ethers.utils.parseEther("1");

      await tokenManagementContract.connect(addr1).buy({
        value: bnbOfTokenToBuy,
      });

      const amountToSell = ethers.utils.parseEther("100");
      await tokenContract
        .connect(addr1)
        .approve(tokenManagementContract.address, amountToSell);

      const tokenMangementAllowance = await tokenContract.allowance(
        addr1.address,
        tokenManagementContract.address
      );
      expect(tokenMangementAllowance).to.equal(amountToSell);

      const sellTx = await tokenManagementContract
        .connect(addr1)
        .sell(amountToSell);

      const tokenMangementBalance = await tokenContract.balanceOf(
        tokenManagementContract.address
      );
      expect(tokenMangementBalance).to.equal(ethers.utils.parseEther("1000"));

      const userTokenBalance = await tokenContract.balanceOf(addr1.address);
      expect(userTokenBalance).to.equal(0);

      const userBnbBalance = ethers.utils.parseEther("1");
      await expect(sellTx).to.changeEtherBalance(addr1, userBnbBalance);
    });
  });
});
