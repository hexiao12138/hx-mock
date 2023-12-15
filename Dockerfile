FROM node:8-alpine
RUN addgroup --system --gid 1001 easy-mock
RUN adduser --system --uid 1001 hx
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
USER hx
RUN npm install \
    && npm run build
