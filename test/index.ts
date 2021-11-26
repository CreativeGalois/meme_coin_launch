import { expect, use } from "chai";
import { ethers } from "hardhat";
import { solidity } from "ethereum-waffle";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

use(solidity);

describe("Token Management", function () {
  let owner: SignerWithAddress;
  let addr1;
  let addr2;
  let addrs;
  const TOTAL_SUPPLY = 1000000000000;

  let tokenManagementContract;
  let tokenFactory;
  let tokenContract;

  let tokenMangementSupply;
  let tokensPerBnb;

  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    tokenFactory = await ethers.getContractFactory("Token");
    tokenContract = await tokenFactory.deploy();

    const TokenManagementContract = await ethers.getContractFactory(
      "TokenManagement"
    );
    tokenManagementContract = await TokenManagementContract.deploy(
      tokenContract.address,
      owner.toString(),
      addr1.toString(),
      addr2.toString()
    );

    await tokenContract.transfer(
      tokenManagementContract.address,
      ethers.utils.parseEther(TOTAL_SUPPLY.toString())
    );

    tokenMangementSupply = await tokenContract.balanceOf(
      tokenManagementContract.address
    );
    tokensPerBnb = await tokenManagementContract.TOKENSPERBNB();
  });

  it("Should return the new greeting once it's changed", async function () {
    const ownerAddress = process.env.OWNERADDRESS!;
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy(ownerAddress);
    await token.deployed();

    const totalSupply = await token.totalSupply();
    console.log(totalSupply.toString());

    expect(await token.totalSupply()).to.equal("1000000000000");

    const ownerBalance = await token.balanceOf(ownerAddress);
    expect(ownerBalance).equal("1000000000000");
  });
});
