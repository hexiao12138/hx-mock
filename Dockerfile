FROM node:8-alpine
RUN addgroup --system --gid 1001 easy-mock
RUN adduser --system --uid 1001 hx
WORKDIR /app
COPY --chown=hx . .
USER hx
USER root
RUN chown -R hx /app
USER hx
RUN npm install \
    && npm run build
