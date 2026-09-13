#!/bin/bash

set -euo pipefail

SSH_KEY="$HOME/.ssh/vaultwarden_backup"
REMOTE="vortex42@pi5-nube"
REMOTE_ROOT="/srv/backups"
TMP="/tmp/vortex42-backups"
DATE="$(date '+%Y-%m-%d_%H-%M-%S')"
RETENTION=14

NTFY_URL="http://127.0.0.1:8083/vortex42-alertas"
#NTFY_URL="https://ntfy.vortex42.local/vortex42-alertas"

# Si ocurre un error mientras un contenedor está detenido,
# esta variable permite volver a iniciarlo.
STOPPED_CONTAINER=""

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

cleanup() {
    if [ -n "$STOPPED_CONTAINER" ]; then
        if ! docker ps --format '{{.Names}}' | grep -qx "$STOPPED_CONTAINER"; then
            echo "Reiniciando $STOPPED_CONTAINER después de un error..."
            docker start "$STOPPED_CONTAINER" >/dev/null || true
        fi
    fi
}

on_error() {
    local exit_code=$?

    notify \
        "❌ Backup servidor falló" \
        "El backup de servicios de vortex42-server falló. Código de salida: ${exit_code}" \
        "5"

    exit "$exit_code"
}

trap on_error ERR
trap cleanup EXIT

mkdir -p "$TMP"

backup_volume() {
    local CONTAINER="$1"
    local DESTINATION="$2"
    local REMOTE_NAME="$3"
    local VOLUME
    local FILE

    VOLUME="$(
        docker inspect "$CONTAINER" \
            --format "{{range .Mounts}}{{if eq .Destination \"$DESTINATION\"}}{{.Name}}{{end}}{{end}}"
    )"

    if [ -z "$VOLUME" ]; then
        echo "ERROR: no se encontró volumen para $CONTAINER:$DESTINATION"
        return 1
    fi

    FILE="${REMOTE_NAME}_${DATE}.tar.gz"

    echo
    echo "=== $CONTAINER ==="
    echo "Volumen: $VOLUME"

    STOPPED_CONTAINER="$CONTAINER"

    docker stop "$CONTAINER" >/dev/null

    docker run --rm \
        -v "${VOLUME}:/source:ro" \
        -v "${TMP}:/backup" \
        alpine \
        tar -czf "/backup/${FILE}" -C /source .

    docker start "$CONTAINER" >/dev/null

    STOPPED_CONTAINER=""

    ssh -i "$SSH_KEY" "$REMOTE" \
        "mkdir -p '${REMOTE_ROOT}/${REMOTE_NAME}'"

    scp -i "$SSH_KEY" \
        "${TMP}/${FILE}" \
        "${REMOTE}:${REMOTE_ROOT}/${REMOTE_NAME}/${FILE}"

    rm -f "${TMP}/${FILE}"
}

echo "=== Backup servicios vortex42-server ==="
echo "Fecha: $(date)"

# Verificar conexión con pi5-nube antes de detener servicios
ssh -i "$SSH_KEY" \
    -o BatchMode=yes \
    -o ConnectTimeout=10 \
    "$REMOTE" \
    "hostname" >/dev/null

backup_volume "portainer" "/data" "portainer"
backup_volume "uptime-kuma" "/app/data" "uptime-kuma"
backup_volume "nginx-proxy-manager" "/data" "nginx-proxy-manager"
backup_volume "actual-budget" "/data" "actual-budget"
backup_volume "gitea" "/data" "gitea"
backup_volume "filebrowser" "/database" "filebrowser-db"
backup_volume "filebrowser" "/config" "filebrowser-config"
backup_volume "ntfy" "/etc/ntfy" "ntfy-config"
backup_volume "ntfy" "/var/cache/ntfy" "ntfy-cache"

# Certificados de Nginx Proxy Manager
NPM_CERT_VOLUME="$(
    docker inspect nginx-proxy-manager \
        --format '{{range .Mounts}}{{if eq .Destination "/etc/letsencrypt"}}{{.Name}}{{end}}{{end}}'
)"

if [ -n "$NPM_CERT_VOLUME" ]; then
    echo
    echo "=== Certificados Nginx Proxy Manager ==="

    STOPPED_CONTAINER="nginx-proxy-manager"

    docker stop nginx-proxy-manager >/dev/null

    docker run --rm \
        -v "${NPM_CERT_VOLUME}:/source:ro" \
        -v "${TMP}:/backup" \
        alpine \
        tar -czf "/backup/npm-certificates_${DATE}.tar.gz" -C /source .

    docker start nginx-proxy-manager >/dev/null

    STOPPED_CONTAINER=""

    scp -i "$SSH_KEY" \
        "${TMP}/npm-certificates_${DATE}.tar.gz" \
        "${REMOTE}:${REMOTE_ROOT}/nginx-proxy-manager/"

    rm -f "${TMP}/npm-certificates_${DATE}.tar.gz"
fi

# Homepage: configuración / bind mount
echo
echo "=== Homepage ==="

tar -czf "${TMP}/homepage_${DATE}.tar.gz" \
    -C "$HOME/vortex42-homelab/docker" homepage

scp -i "$SSH_KEY" \
    "${TMP}/homepage_${DATE}.tar.gz" \
    "${REMOTE}:${REMOTE_ROOT}/homepage/"

rm -f "${TMP}/homepage_${DATE}.tar.gz"

# Repo completo del homelab
echo
echo "=== vortex42-homelab ==="

tar \
    --exclude='.git' \
    --exclude='backups' \
    --exclude='downloads' \
    --exclude='temp' \
    -czf "${TMP}/vortex42-homelab_${DATE}.tar.gz" \
    -C "$HOME" vortex42-homelab

scp -i "$SSH_KEY" \
    "${TMP}/vortex42-homelab_${DATE}.tar.gz" \
    "${REMOTE}:${REMOTE_ROOT}/vortex42-homelab/"

rm -f "${TMP}/vortex42-homelab_${DATE}.tar.gz"

# Retención
echo
echo "Aplicando retención de ${RETENTION} días..."

ssh -i "$SSH_KEY" "$REMOTE" \
    "find '$REMOTE_ROOT' -type f -name '*.tar.gz' -mtime +$RETENTION -delete"

echo
echo "Backup completado correctamente."

notify \
    "✅ Backup servidor OK" \
    "Backup de servicios de vortex42-server completado correctamente." \
    "3"
