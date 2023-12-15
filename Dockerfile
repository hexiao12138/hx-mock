FROM node:8-alpine
RUN addgroup --system --gid 1001 easy-mock
RUN adduser --system --uid 1001 hx
USER hx
WORKDIR /app
COPY . .
RUN npm run build
