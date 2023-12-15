FROM node:8-alpine AS base

# add user group, user and make user home dir
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

WORKDIR /app

USER easy-mock

COPY . .
RUN npm install

RUN npm run build
