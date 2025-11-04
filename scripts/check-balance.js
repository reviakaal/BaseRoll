const { Wallet, JsonRpcProvider, parseEther, formatEther } = require("ethers");

async function main() {
  const network = process.argv[2] || "baseSepolia";
  const minEthStr = process.argv[3] || "0.02";
  const pk = process.env.PRIVATE_KEY;
  if (!pk) throw new Error("PRIVATE_KEY is required");
  const url =
    network === "base"
      ? process.env.BASE_MAINNET_RPC_URL
      : process.env.BASE_SEPOLIA_RPC_URL;
  if (!url) throw new Error("RPC URL is missing for selected network");
  const provider = new JsonRpcProvider(url);
  const wallet = new Wallet(pk, provider);
  const bal = await provider.getBalance(wallet.address);
  const min = parseEther(minEthStr);
  console.log(`Network: ${network}`);
  console.log(`Address: ${wallet.address}`);
  console.log(`Balance: ${formatEther(bal)} ETH`);
  if (bal < min) {
    console.error(`Insufficient funds. Need at least ${minEthStr} ETH`);
    process.exit(1);
  }
}

main().catch((e) => {
  console.error(e.message || String(e));
  process.exit(1);
});
