#!/bin/bash

set -euo pipefail

SSH_KEY="$HOME/.ssh/vaultwarden_backup"
REMOTE="vortex42@pi5-nube"
REMOTE_ROOT="/srv/backups"
TMP="/tmp/vortex42-backups"
DATE="$(date '+%Y-%m-%d_%H-%M-%S')"
RETENTION=14

mkdir -p "$TMP"

backup_volume() {
    CONTAINER="$1"
    DESTINATION="$2"
    REMOTE_NAME="$3"

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

    docker stop "$CONTAINER" >/dev/null

    docker run --rm \
        -v "${VOLUME}:/source:ro" \
        -v "${TMP}:/backup" \
        alpine \
        tar -czf "/backup/${FILE}" -C /source .

    docker start "$CONTAINER" >/dev/null

    scp -i "$SSH_KEY" \
        "${TMP}/${FILE}" \
        "${REMOTE}:${REMOTE_ROOT}/${REMOTE_NAME}/${FILE}"

    rm -f "${TMP}/${FILE}"
}

echo "=== Backup servicios vortex42-server ==="
echo "Fecha: $(date)"

ssh -i "$SSH_KEY" -o BatchMode=yes "$REMOTE" "hostname" >/dev/null

backup_volume "portainer" "/data" "portainer"
backup_volume "uptime-kuma" "/app/data" "uptime-kuma"
backup_volume "nginx-proxy-manager" "/data" "nginx-proxy-manager"

# Certificados NPM
NPM_CERT_VOLUME="$(
    docker inspect nginx-proxy-manager \
    --format '{{range .Mounts}}{{if eq .Destination "/etc/letsencrypt"}}{{.Name}}{{end}}{{end}}'
)"

if [ -n "$NPM_CERT_VOLUME" ]; then
    docker stop nginx-proxy-manager >/dev/null

    docker run --rm \
        -v "${NPM_CERT_VOLUME}:/source:ro" \
        -v "${TMP}:/backup" \
        alpine \
        tar -czf "/backup/npm-certificates_${DATE}.tar.gz" -C /source .

    docker start nginx-proxy-manager >/dev/null

    scp -i "$SSH_KEY" \
        "${TMP}/npm-certificates_${DATE}.tar.gz" \
        "${REMOTE}:${REMOTE_ROOT}/nginx-proxy-manager/"

    rm -f "${TMP}/npm-certificates_${DATE}.tar.gz"
fi

# Homepage: configuración versionada/bind mount
tar -czf "${TMP}/homepage_${DATE}.tar.gz" \
    -C "$HOME/vortex42-homelab/docker" homepage

scp -i "$SSH_KEY" \
    "${TMP}/homepage_${DATE}.tar.gz" \
    "${REMOTE}:${REMOTE_ROOT}/homepage/"

rm -f "${TMP}/homepage_${DATE}.tar.gz"

# Repo completo
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
ssh -i "$SSH_KEY" "$REMOTE" \
    "find '$REMOTE_ROOT' -type f -name '*.tar.gz' -mtime +$RETENTION -delete"

echo
echo "Backup completado."
