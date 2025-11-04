const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);

  const Impl = await ethers.getContractFactory("BaseRollPayroll");
  const proxy = await upgrades.deployProxy(Impl, [deployer.address], { kind: "uups" });
  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  console.log("Proxy:", proxyAddress);
  try {
    const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log("Implementation:", implAddress);
  } catch {
    console.log("Implementation: unavailable, try later");
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
