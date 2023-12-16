FROM registry.cn-shenzhen.aliyuncs.com/hxsz/baseimage:1.4
RUN npm config set registry https://registry.npm.taobao.org
RUN addgroup --system --gid 1001 easy-mock
RUN adduser --system --uid 1001 hx
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
USER hx
RUN npm run build
