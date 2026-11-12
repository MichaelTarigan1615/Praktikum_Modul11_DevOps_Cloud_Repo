# Stage 1: Dependencies & Build
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev && npm cache clean --force

# Stage 2: Production Runtime (Immutable & Least Privilege)
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8080

# Gunakan non-root user untuk lulus standar keamanan container
RUN addgroup -g 1001 -S nodejs && adduser -S appuser -u 1001 -G nodejs
COPY --from=deps --chown=appuser:nodejs /app/node_modules ./node_modules
COPY --chown=appuser:nodejs src/ ./src/
COPY --chown=appuser:nodejs package.json ./

USER appuser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["node", "src/server.js"]
