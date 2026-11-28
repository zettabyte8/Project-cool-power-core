// SPDX-License-Identifier: MIT
// Cool Power Core Reserve Coin (CPC-COIN v5.0) - Hardhat Multi-Chain Deployment & Verification Script
// Networks: Base Mainnet (Chain ID: 8453) & Robinhood Chain L2 (Chain ID: 46630)
// Inventor & Architect: Thomas Gabriel Coleman (Corona, CA)

const hre = require("hardhat");

// Pre-configured Treasury & Inventor Patronage Endpoints
const GNOSIS_SAFE_TREASURY = "0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37";
const INVENTOR_EVM_DONATE  = "0x1419734ee0d1e213f4496d6bf088cc3b480ccedf";

// Canonical Token Addresses by Chain ID
const NETWORK_ASSETS = {
  8453: { // Base Mainnet
    name: "Base Mainnet",
    usdc: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
    wstETH: "0xc1CBa3fCea344f92D9239c08C0568f6F2F0ee452",
    cbBTC: "0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf",
    aeroRouter: "0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43",
    beefyVaultUSDC: "0x0000000000000000000000000000000000000001" // Replace with active Base Beefy vault
  },
  46630: { // Robinhood Chain L2
    name: "Robinhood Chain L2",
    usdc: "0x0000000000000000000000000000000000000002", // Replace with canonical RH L2 USDC
    wstETH: "0x0000000000000000000000000000000000000003", // Replace with canonical RH L2 wstETH
    cbBTC: "0x0000000000000000000000000000000000000004", // Replace with canonical RH L2 BTC
    aeroRouter: "0x0000000000000000000000000000000000000000",
    beefyVaultUSDC: "0x0000000000000000000000000000000000000005"
  }
};

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const network = await hre.ethers.provider.getNetwork();
  const chainId = Number(network.chainId);
  const cfg = NETWORK_ASSETS[chainId] || NETWORK_ASSETS[8453];

  console.log("==================================================================");
  console.log(`Deploying CoolPowerCoreReserveCoinV5 on ${cfg.name} (Chain ID: ${chainId})`);
  console.log(`Deployer Account      : ${deployer.address}`);
  console.log(`Gnosis Safe Treasury  : ${GNOSIS_SAFE_TREASURY}`);
  console.log(`Inventor EVM Endpoint : ${INVENTOR_EVM_DONATE}`);
  console.log("==================================================================");

  const CPCFactory = await hre.ethers.getContractFactory("CoolPowerCoreReserveCoinV5");
  const cpc = await CPCFactory.deploy(GNOSIS_SAFE_TREASURY, INVENTOR_EVM_DONATE);
  await cpc.waitForDeployment();
  const cpcAddress = await cpc.getAddress();

  console.log(`✅ CoolPowerCoreReserveCoinV5 deployed at: ${cpcAddress}`);

  // Register baseline multi-currency reserve assets (1e8 USD oracle feed placeholders)
  if (chainId === 8453) {
    console.log("Configuring Base Mainnet canonical reserve assets...");
    await (await cpc.addReserveAsset(cfg.usdc, "0x7e860098F58bBFC8648a4311b374B1D669a2bc6B", 6)).wait();
    await (await cpc.addReserveAsset(cfg.wstETH, "0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70", 18)).wait();
    await (await cpc.addReserveAsset(cfg.cbBTC, "0x64c911996D3c6aC71f9b455B1E8E7266BcbD848F", 8)).wait();
    console.log("✅ Canonical Base assets registered.");
  }

  // Verify on Basescan / Blockscout
  console.log("Waiting 30s before block explorer verification...");
  await new Promise((r) => setTimeout(r, 30000));
  try {
    await hre.run("verify:verify", {
      address: cpcAddress,
      constructorArguments: [GNOSIS_SAFE_TREASURY, INVENTOR_EVM_DONATE],
    });
    console.log("✅ Contract source verified on explorer.");
  } catch (err) {
    console.log("ℹ️ Verification note:", err.message);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
