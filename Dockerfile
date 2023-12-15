FROM node:8-alpine
RUN npm config set registry https://registry.npm.taobao.org
RUN addgroup --system --gid 1001 easy-mock
RUN adduser --system --uid 1001 hx
WORKDIR /app
RUN apk update && apk add --no-cache git
RUN apk add --no-cache python
COPY package.json ./
RUN npm install
COPY . .
USER hx
RUN npm run build
