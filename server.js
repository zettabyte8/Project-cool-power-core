/**
 * Cool Power Core™: Horizons Unbound — Shared-World Multiplayer Server (v6.1)
 * Inventor & Architect: Thomas Gabriel Coleman (Corona, CA)
 * Supports Tier 0 (Android Mobile Web), Tier 1 (Console), Tier 2 (Desktop+Haptics), Tier 3 (Full-Body Haptic + Brain Hat)
 */
const http = require('http');
const crypto = require('crypto');

const PORT = process.env.PORT || 8080;

// Shared Global Sanctuary City & CPC-COIN State
const worldState = {
  cityName: "Corona-Sanctuary-01 (21.5°C / 48% RH)",
  totalCpcCores: 3900,
  netPowerExportKWe: 422.20,
  pureWaterLPerDay: 253584,
  cpcCoinNavUSD: 1.0842,
  aiMerchantDailyVolumeUSD: 2880000,
  stockTicker: {
    SPY: 618.40,
    NVDA: 162.85,
    AAPL: 244.10,
    TSLA: 358.20,
    GLD: 268.90
  },
  treasuryEndpoints: {
    gnosisSafe: "0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37",
    inventorEvm: "0x1419734ee0d1e213f4496d6bf088cc3b480ccedf",
    inventorBtcCake: "howeyecrypto@cake.cash",
    inventorSol: "2eRUANUAcvyWw1fyHnBSS53g4pWURXcE4se1WRW6H3Nr"
  },
  activePlayers: {}
};

// Deterministic 2,048 AI Merchant NPC Fee Recycling Tick (every 3 seconds)
setInterval(() => {
  const tradeBatchUSD = 8500 + Math.random() * 4200;
  const swapFeeUSD = tradeBatchUSD * 0.0025; // 0.25% swap fee recycled into NAV
  worldState.aiMerchantDailyVolumeUSD += tradeBatchUSD;
  worldState.cpcCoinNavUSD = +(worldState.cpcCoinNavUSD + swapFeeUSD * 0.0000004).toFixed(6);

  // Mild real-world stock mirror drift
  for (const sym of Object.keys(worldState.stockTicker)) {
    const delta = (Math.random() - 0.495) * 0.0035;
    worldState.stockTicker[sym] = +(worldState.stockTicker[sym] * (1 + delta)).toFixed(2);
  }
}, 3000);

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');

  if (req.url === '/api/state' && req.method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify({ ok: true, timestamp: Date.now(), worldState }));
    return;
  }

  if (req.url === '/api/sync' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => (body += chunk));
    req.on('end', () => {
      try {
        const data = JSON.parse(body || '{}');
        const playerId = String(data.playerId || crypto.randomUUID()).slice(0, 48);
        const addedCores = Math.max(0, Math.min(500, Number(data.addedCores || 0)));
        worldState.totalCpcCores += addedCores;
        worldState.netPowerExportKWe = +(worldState.totalCpcCores * 0.10825).toFixed(2);
        worldState.pureWaterLPerDay = Math.round(worldState.totalCpcCores * 65.02);
        worldState.activePlayers[playerId] = {
          tier: data.tier || 'Tier 0 (Mobile)',
          x: Number(data.x || 0),
          y: Number(data.y || 0),
          z: Number(data.z || 0),
          updatedAt: Date.now()
        };
        res.writeHead(200);
        res.end(JSON.stringify({ ok: true, playerId, worldState }));
      } catch (err) {
        res.writeHead(400);
        res.end(JSON.stringify({ ok: false, error: 'Invalid JSON payload' }));
      }
    });
    return;
  }

  res.writeHead(200);
  res.end(JSON.stringify({
    service: "Cool Power Core™: Horizons Unbound Shared-World Sync Server",
    endpoints: ["GET /api/state", "POST /api/sync"],
    inventor: "Thomas Gabriel Coleman"
  }));
});

server.listen(PORT, () => {
  console.log(`[CPC-SERVER] Shared-World Sanctuary Server listening on port ${PORT}`);
});
