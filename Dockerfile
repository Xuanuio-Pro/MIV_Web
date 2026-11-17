FROM node:22-alpine
WORKDIR /app
COPY server.js claude-shim.js login.html phong-cham-miv2026.html ./
ENV PORT=8080 DATA_DIR=/app/data NODE_ENV=production
RUN mkdir -p /app/data && chown node:node /app/data
USER node
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
CMD ["node", "server.js"]
