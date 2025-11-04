const { ethers, upgrades } = require("hardhat");

async function main() {
  const proxyAddress = process.env.PROXY_ADDRESS;
  if (!proxyAddress) throw new Error("Set PROXY_ADDRESS");

  const Impl = await ethers.getContractFactory("BaseRollPayroll");
  const upgraded = await upgrades.upgradeProxy(proxyAddress, Impl);
  await upgraded.waitForDeployment();

  console.log("Upgraded proxy:", proxyAddress);
  try {
    const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log("New implementation:", implAddress);
  } catch {
    console.log("Implementation: unavailable, try later");
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
