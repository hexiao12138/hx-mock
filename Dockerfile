FROM node:8-alpine AS base

# add user group, user and make user home dir
RUN addgroup -g 1000 easy-mock && \
    adduser -D -u 1000 -G easy-mock easy-mock

WORKDIR /app

USER easy-mock

COPY . .
RUN npm install

RUN npm run build