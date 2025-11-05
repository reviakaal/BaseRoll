const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("BaseRollPayroll", function () {
  it("initializes and pays ETH", async () => {
    const [owner, alice] = await ethers.getSigners();
    const Impl = await ethers.getContractFactory("BaseRollPayroll");
    const proxy = await upgrades.deployProxy(Impl, [owner.address], { kind: "uups" });
    await proxy.waitForDeployment();

    await owner.sendTransaction({ to: await proxy.getAddress(), value: ethers.parseEther("1") });
    await proxy.addPayee(alice.address, ethers.parseEther("0.1"));

    const before = await ethers.provider.getBalance(alice.address);
    await proxy.processPayroll(5);
    const after = await ethers.provider.getBalance(alice.address);
    expect(after - before).to.equal(ethers.parseEther("0.1"));
  });

  it("pauses payouts", async () => {
    const [owner, alice] = await ethers.getSigners();
    const Impl = await ethers.getContractFactory("BaseRollPayroll");
    const proxy = await upgrades.deployProxy(Impl, [owner.address], { kind: "uups" });
    await owner.sendTransaction({ to: await proxy.getAddress(), value: ethers.parseEther("1") });
    await proxy.addPayee(alice.address, ethers.parseEther("0.01"));

    await proxy.pause();
    await expect(proxy.processPayroll(1)).to.be.revertedWithCustomError(proxy, "EnforcedPause");
    await proxy.unpause();
    await proxy.processPayroll(1);
  });
});
