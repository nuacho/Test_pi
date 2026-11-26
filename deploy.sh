#!/usr/bin/env bash
#
# deploy.sh — деплой todo-приложения на удалённый сервер.
#
# Что делает:
#   1. Собирает tar-архив с исходниками проекта (то, что сейчас на вашем ПК).
#   2. Заливает его на сервер по SSH.
#   3. На сервере: распаковывает, собирает Docker-образ, перезапускает systemd-сервис.
#   4. Проверяет, что приложение отвечает на порту 3000.
#
# Запуск из корня проекта:
#   bash deploy.sh
#
set -euo pipefail

# ----- Конфигурация (можно переопределить переменными окружения) -----
HOST="${DEPLOY_HOST:-104.253.134.74}"
SSH_PORT="${DEPLOY_SSH_PORT:-22}"
USER="${DEPLOY_USER:-root}"
KEY="${DEPLOY_KEY:-$HOME/.ssh/id_ed25519}"
APP_DIR="${DEPLOY_APP_DIR:-/opt/todo-app}"     # куда распаковывать на сервере
SERVICE="${DEPLOY_SERVICE:-todo-app}"          # имя systemd-сервиса
HTTP_PORT="${DEPLOY_HTTP_PORT:-3000}"          # порт приложения на сервере

SSH_OPTS=(-i "$KEY" -p "$SSH_PORT" -o StrictHostKeyChecking=accept-new -o BatchMode=yes)
SSH_CMD=(ssh "${SSH_OPTS[@]}" "$USER@$HOST")
SCP_CMD=(scp -i "$KEY" -P "$SSH_PORT" -o StrictHostKeyChecking=accept-new -o BatchMode=yes)

log()  { printf '\033[1;34m[deploy]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[deploy] ОШИБКА:\033[0m %s\n' "$*" >&2; exit 1; }

# ----- 0. Проверки -----
cd "$(dirname "$0")"

for f in Dockerfile docker-compose.yml package.json package-lock.json vite.config.js index.html server/server.js; do
  [ -f "$f" ] || fail "не найден $f — запускайте скрипт из корня проекта"
done

log "Проверка связи с $HOST..."
"${SSH_CMD[@]}" true 2>/dev/null || fail "нет SSH-доступа к $USER@$HOST:$SSH_PORT"

# ----- 1. Архив исходников -----
TARBALL="$(mktemp -u /tmp/todo-app-XXXX).tar.gz"
log "Упаковка исходников в $(basename "$TARBALL")..."
tar -czf "$TARBALL" \
  Dockerfile .dockerignore docker-compose.yml \
  package.json package-lock.json vite.config.js index.html \
  src server

# ----- 2. Заливка на сервер -----
log "Загрузка на сервер..."
"${SCP_CMD[@]}" "$TARBALL" "$USER@$HOST:/tmp/todo-app-deploy.tar.gz"
rm -f "$TARBALL"

# ----- 3. Сборка и запуск на сервере (docker compose) -----
log "Сборка образа и перезапуск сервиса на сервере..."
"${SSH_CMD[@]}" bash -s <<REMOTE
set -euo pipefail

APP_DIR='$APP_DIR'
SERVICE='$SERVICE'
HTTP_PORT='$HTTP_PORT'

# Docker + compose: ставим, если отсутствуют
if ! command -v docker >/dev/null 2>&1; then
  echo "[deploy] Docker не найден — устанавливаю..."
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker.io docker-compose-v2 >/dev/null
  systemctl enable --now docker
fi

mkdir -p "\$APP_DIR"
tar -xzf /tmp/todo-app-deploy.tar.gz -C "\$APP_DIR"
rm -f /tmp/todo-app-deploy.tar.gz

# общая сеть для nginx-proxy
if ! docker network inspect nginx-proxy >/dev/null 2>&1; then
  docker network create nginx-proxy
fi

# systemd-сервис: создаём/обновляем
cat > "\$APP_DIR/\$SERVICE.service" <<UNIT
[Unit]
Description=Todo List app (Docker Compose)
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=simple
Restart=always
RestartSec=5
WorkingDirectory=\$APP_DIR
ExecStartPre=-/usr/bin/docker compose -f \$APP_DIR/docker-compose.yml down --remove-orphans
ExecStart=/usr/bin/docker compose -f \$APP_DIR/docker-compose.yml up --build --abort-on-container-exit
ExecStop=/usr/bin/docker compose -f \$APP_DIR/docker-compose.yml down --remove-orphans
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload

if ! systemctl cat "\$SERVICE" >/dev/null 2>&1; then
  systemctl link "\$APP_DIR/\$SERVICE.service"
fi
systemctl enable "\$SERVICE"

# в compose перезапуск осуществляется через сервис
docker compose -f "\$APP_DIR/docker-compose.yml" build --pull -q
systemctl restart "\$SERVICE"

# ждём, пока приложение начнёт отвечать
for i in \$(seq 1 30); do
  code=\$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:\$HTTP_PORT/" || true)
  [ "\$code" = "200" ] && break
  sleep 1
done
[ "\$code" = "200" ] || { journalctl -u "\$SERVICE" -n 30 --no-pager; exit 1; }
echo "[deploy] Сервер отвечает: HTTP \$code"
REMOTE

# ----- 4. Финальная проверка снаружи -----
log "Проверка снаружи: http://$HOST:$HTTP_PORT/"
code="$(curl -s -o /dev/null -w '%{http_code}' -m 15 "http://$HOST:$HTTP_PORT/" || true)"
if [ "$code" = "200" ]; then
  log "Готово ✅  Приложение доступно на http://$HOST:$HTTP_PORT/"
else
  fail "приложение не отвечает снаружи (HTTP $code). Возможна блокировка порта файрволом провайдера."
fi
