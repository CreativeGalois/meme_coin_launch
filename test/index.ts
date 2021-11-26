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
  let tokenContract;

  let tokenMangementSupply;
  let tokensPerBnb;

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
      ethers.utils.parseEther("1000000000000")
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
  });

  // it("Should return the new greeting once it's changed", async function () {
  //   const ownerAddress = process.env.OWNERADDRESS!;
  //   const Token = await ethers.getContractFactory("Token");
  //   const token = await Token.deploy(ownerAddress);
  //   await token.deployed();

  //   const totalSupply = await token.totalSupply();
  //   console.log(totalSupply.toString());

  //   expect(await token.totalSupply()).to.equal("1000000000000");

  //   const ownerBalance = await token.balanceOf(ownerAddress);
  //   expect(ownerBalance).equal("1000000000000");
  // });
});
