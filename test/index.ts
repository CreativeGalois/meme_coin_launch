import { expect } from "chai";
import { ethers } from "hardhat";

describe("Token", function () {
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
