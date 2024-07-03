const { expect } = require("chai");

describe("ETHVaultContract", function () {
  it("Should return the correct balance after deposit", async function () {
    const [owner] = await ethers.getSigners();

    const ETHVaultContract = await ethers.getContractFactory(
      "ETHVaultContract",
    );
    const contract = await ETHVaultContract.deploy();
    await contract.deployed();

    await contract.deposit({ value: ethers.utils.parseEther("1.0") });

    expect(await contract.getUserBalance(owner.address)).to.equal(
      ethers.utils.parseEther("1.0"),
    );
  });
});
