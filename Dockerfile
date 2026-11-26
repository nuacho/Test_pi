# --- Сборка фронтенда ---
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY vite.config.js index.html ./
COPY src ./src
RUN npm run build

# --- Рантайм: только статика + сервер раздачи ---
FROM node:22-alpine

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

COPY server/package.json ./server/
COPY server/server.js ./server/
COPY --from=build /app/dist ./dist

EXPOSE 3000

# Health-check внутри контейнера
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "server/server.js"]
