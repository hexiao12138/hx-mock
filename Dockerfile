FROM registry.cn-shenzhen.aliyuncs.com/hxsz/baseimage:1.4
RUN npm config set registry https://registry.npm.taobao.org
RUN addgroup --system --gid 1001 easyMock
RUN adduser --system --uid 1001 hx
WORKDIR /app
# RUN npm install -g node-gyp
COPY . .
RUN mkdir dist
RUN chown hx:easyMock dist
RUN chown hx:easyMock views/config.json
RUN npm install
USER hx
RUN npm run build
