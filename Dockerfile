FROM node:12.16.3 as base

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci

COPY tsconfig*.json ./
COPY ./src ./src
RUN npm run build

FROM node:12.16.3-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --production

COPY --from=base /usr/src/app/dist ./dist

ENV NODE_ENV=production

ENV PORT=4000

EXPOSE 4000
CMD ["node", "dist/main.js"]
