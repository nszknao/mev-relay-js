FROM node:20-alpine3.18 AS base
RUN npm i -g pnpm
WORKDIR /app

# Install dependencies only when needed
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN apk update \
  && pnpm install

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN pnpm prune --prod

# Production image, copy all the files and run
FROM base
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server ./server
COPY --from=builder /app/package.json ./package.json
EXPOSE 18545
EXPOSE 9090

CMD ["pnpm", "start"]
