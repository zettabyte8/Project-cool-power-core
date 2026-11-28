const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const network = await hre.ethers.provider.getNetwork();
  console.log(`Deploying Cool Power Core v6.8 Full Stack on Chain ID: ${network.chainId} via ${deployer.address}`);

  const GNOSIS_SAFE = "0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37";
  const INVENTOR_PATRONAGE = "0x1419734ee0d1e213f4496d6bf088cc3b480ccedf";

  // 1. Deploy CPC-COIN v6.0 Multi-Currency Reserve & Fair ETF Dividend Engine
  const ReserveCoin = await hre.ethers.getContractFactory("CoolPowerCoreReserveCoinV6");
  const cpc = await ReserveCoin.deploy(GNOSIS_SAFE, INVENTOR_PATRONAGE);
  await cpc.waitForDeployment();
  const cpcAddress = await cpc.getAddress();
  console.log(`CoolPowerCoreReserveCoinV6 deployed to: ${cpcAddress}`);

  // 2. Deploy Physical Manufacturing & Shipping Escrow linked to CPC-COIN
  const Fulfillment = await hre.ethers.getContractFactory("CoolPowerCoreHardwareFulfillment");
  const fulfillment = await Fulfillment.deploy(cpcAddress, GNOSIS_SAFE);
  await fulfillment.waitForDeployment();
  const fulfillmentAddress = await fulfillment.getAddress();
  console.log(`CoolPowerCoreHardwareFulfillment deployed to: ${fulfillmentAddress}`);

  console.log("\nNext Step (via Gnosis Safe 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37):");
  console.log("  1. Call registerSKU(1..6, skuCode, priceCPC18, batchCap) for launch hardware catalog.");
  console.log("  2. Keep manufacturingAvailable[skuId] = false during pre-order escrow phase (100% refundable).");
  console.log("  3. Toggle setManufacturingAvailable(skuId, true) when Corona, CA assembly line opens Batch 1.");

  if (network.chainId === 8453n || network.chainId === 46630n) {
    try {
      await hre.run("verify:verify", {
        address: cpcAddress,
        constructorArguments: [GNOSIS_SAFE, INVENTOR_PATRONAGE],
      });
      await hre.run("verify:verify", {
        address: fulfillmentAddress,
        constructorArguments: [cpcAddress, GNOSIS_SAFE],
      });
    } catch (err) {
      console.log("Explorer verification queued/skipped:", err.message);
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
