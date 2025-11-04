const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("BaseRollPayroll", function () {
  it("initializes and pays", async () => {
    const [owner, alice] = await ethers.getSigners();
    const Impl = await ethers.getContractFactory("BaseRollPayroll");
    const proxy = await upgrades.deployProxy(Impl, [owner.address], { kind: "uups" });
    await proxy.waitForDeployment();

    await owner.sendTransaction({ to: await proxy.getAddress(), value: ethers.parseEther("1") });
    await proxy.addPayee(alice.address, ethers.parseEther("0.1"));

    const balBefore = await ethers.provider.getBalance(alice.address);
    await proxy.processPayroll(10);
    const balAfter = await ethers.provider.getBalance(alice.address);
    expect(balAfter - balBefore).to.equal(ethers.parseEther("0.1"));
  });
});
