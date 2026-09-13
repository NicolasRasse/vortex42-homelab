#!/bin/bash

set -euo pipefail

CONTAINER="vaultwarden"
SSH_KEY="$HOME/.ssh/vaultwarden_backup"
REMOTE_HOST="vortex42@pi5-nube"
REMOTE_DIR="/srv/backups/vaultwarden"
LOCAL_TMP="/tmp/vaultwarden-backup"
DATE="$(date '+%Y-%m-%d_%H-%M-%S')"
BACKUP_NAME="vaultwarden_${DATE}.tar.gz"
RETENTION_DAYS=14

NTFY_URL="https://ntfy.vortex42.local/vortex42-alertas"

notify() {
  local title="$1"
  local message="$2"
  local priority="$3"

  curl -fsS \
    -H "Title: ${title}" \
    -H "Priority: ${priority}" \
    -d "${message}" \
    "$NTFY_URL" >/dev/null || true
}

on_error() {
  local exit_code=$?

  notify \
    "❌ Backup Vaultwarden falló" \
    "El backup de Vaultwarden falló en vortex42-server. Código de salida: ${exit_code}" \
    "5"

  exit "$exit_code"
}

cleanup() {
  if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    echo "Reiniciando Vaultwarden..."
    docker start "$CONTAINER" >/dev/null || true
  fi
}

trap on_error ERR

echo "=== Backup Vaultwarden ==="
echo "Fecha: $(date)"

mkdir -p "$LOCAL_TMP"

# Detectar el volumen montado en /data
VOLUME="$(
  docker inspect "$CONTAINER" \
    --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Name}}{{end}}{{end}}'
)"

if [ -z "$VOLUME" ]; then
  echo "ERROR: no se pudo detectar el volumen de Vaultwarden."
  exit 1
fi

echo "Volumen detectado: $VOLUME"

# Verificar SSH antes de tocar Vaultwarden
ssh -i "$SSH_KEY" \
  -o BatchMode=yes \
  -o ConnectTimeout=10 \
  "$REMOTE_HOST" \
  "mkdir -p '$REMOTE_DIR'"

trap cleanup EXIT

echo "Deteniendo Vaultwarden..."
docker stop "$CONTAINER" >/dev/null

echo "Creando backup..."
docker run --rm \
  -v "${VOLUME}:/data:ro" \
  -v "${LOCAL_TMP}:/backup" \
  alpine \
  tar -czf "/backup/${BACKUP_NAME}" -C /data .

echo "Iniciando Vaultwarden..."
docker start "$CONTAINER" >/dev/null
trap - EXIT

echo "Copiando backup a pi5-nube..."
scp -i "$SSH_KEY" \
  "${LOCAL_TMP}/${BACKUP_NAME}" \
  "${REMOTE_HOST}:${REMOTE_DIR}/${BACKUP_NAME}"

echo "Eliminando copia temporal..."
rm -f "${LOCAL_TMP}/${BACKUP_NAME}"

echo "Aplicando retención de ${RETENTION_DAYS} días..."
ssh -i "$SSH_KEY" "$REMOTE_HOST" \
  "find '$REMOTE_DIR' -type f -name 'vaultwarden_*.tar.gz' -mtime +${RETENTION_DAYS} -delete"

echo
echo "Backup completado correctamente:"
ssh -i "$SSH_KEY" "$REMOTE_HOST" \
  "ls -lh '${REMOTE_DIR}/${BACKUP_NAME}'"

notify \
  "✅ Backup Vaultwarden OK" \
  "Backup completado correctamente: ${BACKUP_NAME}" \
  "3"
