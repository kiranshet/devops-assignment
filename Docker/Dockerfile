FROM node:24-alpine

WORKDIR /app

COPY Application/package*.json ./

RUN npm ci --omit=dev

COPY Application/server.js ./

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

USER node

CMD ["node", "server.js"]
