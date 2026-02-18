FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm i --only=production

COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001

USER appuser

EXPOSE 3000

CMD ["node", "server.js"]
