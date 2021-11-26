import { expect, use } from "chai";
import { ethers } from "hardhat";
import solidity from "ethereum-waffle";

// use(solidity);

describe("Token Management", function () {
  let owner;
  let addr1;
  let addr2;
  let addrs;

  let tokenManagementContract;
  let tokenContract;

  let tokenMangementSupply;
  let tokensPerBnb;

  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    tokenContract = await ethers.getContractFactory("Token");
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
