/* Upgrade implementation
 * Usage: PROXY_ADDRESS=0x... npx hardhat run scripts/upgrade.js --network baseSepolia
 */
const { upgrades } = require("hardhat");

async function main() {
  const proxyAddress = process.env.PROXY_ADDRESS;
  if (!proxyAddress) throw new Error("Set PROXY_ADDRESS env var");

  const Impl = await ethers.getContractFactory("BaseRollPayroll");
  const upgraded = await upgrades.upgradeProxy(proxyAddress, Impl);
  await upgraded.waitForDeployment();

  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  console.log("Upgraded proxy:", proxyAddress);
  console.log("New implementation:", implAddress);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
