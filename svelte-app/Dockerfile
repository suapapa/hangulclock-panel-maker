# --- Node Build Stage (Vite Svelte App) ---
FROM node:20-alpine AS node-builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# --- Production Stage ---
# Rust로 작성된 고성능 정적 웹 서버 사용 (joseluisq/static-web-server)
FROM joseluisq/static-web-server:2-alpine AS prod

# 기본 환경변수 (포트 및 루트 디렉터리 설정)
ENV SERVER_PORT=8080
ENV SERVER_ROOT=/public

# 기존 server.go에서 "/" 와 "/panel-maker/" 모두 지원하도록 한 특성을
# 디렉터리 구조로 구현하여 서버가 그대로 정적 파일을 서빙하게 함
COPY --from=node-builder /app/dist /public/
COPY --from=node-builder /app/dist /public/panel-maker/

EXPOSE $SERVER_PORT