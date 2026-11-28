FROM node:20-alpine

WORKDIR /app

# Copy package manifest and server runtime
COPY package.json ./
COPY server.js ./

# Copy PWA frontend, icons, manifest, and service worker
COPY Cool_Power_Core_Horizons_Playable_Browser_Game.html ./index.html
COPY Cool_Power_Core_Horizons_Playable_Browser_Game.html ./Cool_Power_Core_Horizons_Playable_Browser_Game.html
COPY manifest.webmanifest ./manifest.webmanifest
COPY sw.js ./sw.js
COPY icon-192.png ./icon-192.png
COPY icon-512.png ./icon-512.png
COPY icon-1024.png ./icon-1024.png

ENV PORT=8080
ENV NODE_ENV=production

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:8080/api/state || exit 1

CMD ["node", "server.js"]
