# BaseRoll

**BaseRoll** simulates on-chain payroll payments powered by **Base Pay API** and **smart contracts** deployed on Base Mainnet and Base Sepolia.  
The project demonstrates how periodic salary distribution can be managed through decentralized infrastructure while keeping full auditability on Base.

---

## 🚀 Vision
BaseRoll aims to showcase transparent, verifiable payroll automation entirely on-chain.  
Each release leaves an immutable footprint in Base Mainnet and Testnet, aligning with the broader goal of being recognized among active Base builders.

---

## 🧩 Architecture
- **Proxy pattern (UUPS)** for upgradable contract logic  
- **Base Pay API integration** for micropayments and salary disbursement  
- **GitHub Actions** for automated deployment and upgrade  
- **BaseScan verification** for on-chain provenance  

---

## 🌐 Networks & Deployments
| Network | Chain ID | Proxy Address | Implementation Address |
|----------|-----------|---------------|-------------------------|
| Base Sepolia (Testnet) | 84532 | refer to `.dev/deployments.json` | refer to `.dev/deployments.json` |
| Base Mainnet | 8453 | refer to `.dev/deployments.json` | refer to `.dev/deployments.json` |

Deployment data are automatically consumed by workflows for upgrade and verification.

---

## ⚙️ GitHub Secrets Configuration
| Name | Description |
|------|--------------|
| `BASESCAN_API_KEY` | API key for contract verification |
| `BASE_MAINNET_RPC_URL` | RPC endpoint for Base Mainnet |
| `BASE_SEPOLIA_RPC_URL` | RPC endpoint for Base Sepolia |
| `PRIVATE_KEY` | Deployer wallet private key (UUPS owner) |

All sensitive data are stored in **GitHub Actions secrets** — never exposed in code.

---

## 🪄 How to Deploy via GitHub Actions
1. Commit and push to `main`.  
2. Workflow automatically deploys or upgrades depending on contract version.  
3. Deployed addresses are written to `deployments/{chainId}.json`.  
4. Verified contracts appear on [BaseScan](https://basescan.org).

---

## 🧱 Stack
- Solidity ^0.8.x  
- Foundry / Hardhat tooling  
- OpenZeppelin UUPS Upgrade pattern  
- Base Pay SDK + Base Account SDK  
- GitHub Actions CI/CD  

---

## 🧩 Next Steps
1. Implement minimal payroll logic (`PayrollImplementation.sol`)  
2. Prepare pre-release `v0.1.0-pre`  
3. Deploy UUPS proxy on Base Sepolia and Base Mainnet  
4. Publish verified addresses and release notes  

---

## 📄 License
This project is licensed under the **MIT License** — see [`LICENSE`](./LICENSE) for details.

---

## 🪶 Ecosystem Tags
`base` `base-pay` `coinbase-base` `uups` `openzeppelin-upgrades` `payroll` `smart-contracts` `usdc` `onchain` `solidity` `github-actions` `builder` `electric-capital`
