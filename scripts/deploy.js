/* Deploy UUPS proxy for BaseRollPayroll
 * Usage: npx hardhat run scripts/deploy.js --network baseSepolia
 */
const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);

  const Impl = await ethers.getContractFactory("BaseRollPayroll");
  const proxy = await upgrades.deployProxy(Impl, [deployer.address], {
    kind: "uups",
  });
  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);

  console.log("Proxy:", proxyAddress);
  console.log("Implementation:", implAddress);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
