# Base Node Image
FROM node:14-alpine AS base
WORKDIR /app
RUN npm i -g node-prune

# Couchbase sdk requirements
RUN apk update && apk add bash

# Install dependencies
FROM base AS dependencies
COPY package*.json ./
RUN npm ci && npm cache clean --force

# Copy Files and Build
FROM dependencies AS build
WORKDIR /app
COPY . .
RUN npm run build

# Copy it and remove dev dependencies
FROM build AS prodDependencies
WORKDIR /app
COPY --from=dependencies /app/package*.json ./
COPY --from=dependencies /app/node_modules ./node_modules/
RUN npm prune --production && node-prune

FROM node:14-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=prodDependencies /app/node_modules ./node_modules
EXPOSE 4000
CMD ["node", "./dist/main.js"]
