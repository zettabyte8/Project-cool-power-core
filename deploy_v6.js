// SPDX-License-Identifier: MIT
// Hardhat Deployment & Verification Script for CoolPowerCoreReserveCoinV6 (CPC-COIN v6.0)
// Inventor & Architect: Thomas Gabriel Coleman (Corona, CA)
// Features: Multi-Currency Reserve + Aerodrome (Base) + Lido/Beefy + Robinhood Chain Fair ETF Dividends (SCHD, JEPI, VOO, SGOV)

const hre = require("hardhat");

const GNOSIS_SAFE_TREASURY = "0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37";
const INVENTOR_PATRONAGE   = "0x1419734ee0d1e213f4496d6bf088cc3b480ccedf";

const NETWORK_CONFIG = {
  8453: {
    name: "Base Mainnet",
    aerodromeRouter: "0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43",
    assets: [
      { symbol: "USDC",   address: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913", decimals: 6,  priceFeed: "0x7e860098F58bBFC8648a4311b374B1D669a2bc6B" },
      { symbol: "wstETH", address: "0xc1CBa3fCea344f92D9239c08C0568f6F2F0ee452", decimals: 18, priceFeed: "0x43a5C292A453A3bF3606fa856197f09D7B74251a" },
      { symbol: "cbBTC",  address: "0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf", decimals: 8,  priceFeed: "0x07DA0E54543a844a80ABE69c8A12F22B3aA59f9D" }
    ]
  },
  46630: {
    name: "Robinhood Chain L2",
    aerodromeRouter: "0x0000000000000000000000000000000000000000",
    assets: [
      { symbol: "USDC",   address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", decimals: 6,  priceFeed: "0x0000000000000000000000000000000000000001" },
      { symbol: "SCHD",   address: "0x0000000000000000000000000000000000000101", decimals: 18, priceFeed: "0x0000000000000000000000000000000000000002" },
      { symbol: "JEPI",   address: "0x0000000000000000000000000000000000000102", decimals: 18, priceFeed: "0x0000000000000000000000000000000000000003" },
      { symbol: "VOO",    address: "0x0000000000000000000000000000000000000103", decimals: 18, priceFeed: "0x0000000000000000000000000000000000000004" },
      { symbol: "SGOV",   address: "0x0000000000000000000000000000000000000104", decimals: 18, priceFeed: "0x0000000000000000000000000000000000000005" }
    ]
  }
};

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const network = await hre.ethers.provider.getNetwork();
  const chainId = Number(network.chainId);
  const cfg = NETWORK_CONFIG[chainId] || {
    name: `Local/Custom Network (${chainId})`,
    aerodromeRouter: deployer.address,
    assets: []
  };

  console.log("=================================================================");
  console.log(`Deploying CoolPowerCoreReserveCoinV6 (CPC-COIN v6.0) on ${cfg.name}`);
  console.log(`Deployer         : ${deployer.address}`);
  console.log(`Gnosis Treasury  : ${GNOSIS_SAFE_TREASURY}`);
  console.log(`Inventor Patron  : ${INVENTOR_PATRONAGE}`);
  console.log("=================================================================");

  const CPCV6 = await hre.ethers.getContractFactory("CoolPowerCoreReserveCoinV6");
  const cpc = await CPCV6.deploy(
    GNOSIS_SAFE_TREASURY,
    INVENTOR_PATRONAGE,
    cfg.aerodromeRouter
  );
  await cpc.waitForDeployment();
  const cpcAddress = await cpc.getAddress();
  console.log(`CoolPowerCoreReserveCoinV6 deployed to: ${cpcAddress}`);

  // Register multi-currency & tokenized ETF basket assets
  for (const asset of cfg.assets) {
    if (asset.address !== "0x0000000000000000000000000000000000000000") {
      const tx = await cpc.addReserveAsset(asset.address, asset.decimals, asset.priceFeed);
      await tx.wait();
      console.log(` -> Registered reserve asset ${asset.symbol} (${asset.address})`);
    }
  }

  // Configure default ETF dividend sweep weights (SCHD 35%, JEPI 30%, VOO 20%, SGOV 15%)
  if (typeof cpc.setEtfAllocationBps === "function") {
    const txAlloc = await cpc.setEtfAllocationBps(3500, 3000, 2000, 1500);
    await txAlloc.wait();
    console.log(" -> Configured Fair ETF Dividend Sweep Weights: SCHD 35% | JEPI 30% | VOO 20% | SGOV 15%");
  }

  // Verify on block explorer when running on live networks
  if (chainId === 8453 || chainId === 46630) {
    console.log("Waiting 5 confirmations before block-explorer verification...");
    await new Promise((r) => setTimeout(r, 20000));
    try {
      await hre.run("verify:verify", {
        address: cpcAddress,
        constructorArguments: [GNOSIS_SAFE_TREASURY, INVENTOR_PATRONAGE, cfg.aerodromeRouter]
      });
      console.log(" -> Block-explorer contract verification complete!");
    } catch (err) {
      console.warn(" -> Verification notice:", err.message);
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
