# Cool Power Core™: Multi-Chain Deployment & Interactive Agora Kiosk Guide
**Architect & Inventor:** Thomas Gabriel Coleman (Corona, California)  
**Smart Contract:** `CoolPowerCoreReserveCoinV5.sol` (`CPC-COIN` v5.0)  
**Target Networks:** Base Mainnet (`Chain ID: 8453`) & Robinhood Chain L2 (`Chain ID: 46630`)

---

## 1. Pre-Configured Treasury & Inventor Patronage Endpoints

| Endpoint Role | Network / Protocol | Configured Address / Identifier |
| :--- | :--- | :--- |
| **Investment & Yield Governance Safe** | Multi-Chain EVM (Gnosis Safe) | `0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37` |
| **Thomas Direct EVM Patronage** | Base, Ethereum, Arbitrum, Polygon, RH L2 | `0x1419734ee0d1e213f4496d6bf088cc3b480ccedf` |
| **Bitcoin / Lightning Patronage** | Cake Pay / BTC Network | `howeyecrypto@cake.cash` |
| **Solana Direct Patronage** | Solana Mainnet (`SOL` / `USDC-SPL`) | `2eRUANUAcvyWw1fyHnBSS53g4pWURXcE4se1WRW6H3Nr` |

---

## 2. Hardhat & Foundry Multi-Chain Deployment Steps

### A. Hardhat Deployment (`deploy_and_verify_v5.js`)
```bash
# 1. Install dependencies
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox @openzeppelin/contracts

# 2. Configure .env with DEPLOYER_PRIVATE_KEY and BASESCAN_API_KEY
npx hardhat run generated/deploy_and_verify_v5.js --network base
npx hardhat run generated/deploy_and_verify_v5.js --network robinhoodL2
```

### B. Foundry (`forge`) Single-Command Deployment
```bash
forge create src/CoolPowerCoreReserveCoinV5.sol:CoolPowerCoreReserveCoinV5 \
  --rpc-url $BASE_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --constructor-args 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37 0x1419734ee0d1e213f4496d6bf088cc3b480ccedf \
  --verify --etherscan-api-key $BASESCAN_API_KEY
```

---

## 3. Interactive Agora Kiosk & Stock Exchange UI (`Cool_Power_Core_Agora_Kiosk_UI.html`)
Open `Cool_Power_Core_Agora_Kiosk_UI.html` directly in any desktop, mobile, or WebGPU-capable browser to test:
1. **Live `CPC-COIN` Multi-Currency Minting & NAV Ratchet:** Simulates depositing `USDC`, `ETH/wstETH`, `EURC`, or `cbBTC` and watching **2,048 autonomous AI Merchant NPCs** execute swaps that compound `0.25%` fees into Net Asset Value.
2. **Real-World Stock & ETF Mirror:** Demonstrates live equity trading (`SPY`, `NVDA`, `AAPL`, `MSFT`, `TSLA`, `GLD`, `TLT`) inside subterranean Sanctuary City exchanges.
3. **One-Click Inventor Patronage Endpoints:** Displays your Gnosis Safe, EVM, Cake Pay BTC, and Solana addresses with instant clipboard copy.
