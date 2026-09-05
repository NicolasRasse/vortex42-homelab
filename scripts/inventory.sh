#!/bin/bash

set -e

HOSTNAME=$(hostname)
OUTPUT="inventory/${HOSTNAME}.md"

mkdir -p inventory

{
  echo "# Inventario de ${HOSTNAME}"
  echo
  echo "Generado: $(date '+%Y-%m-%d %H:%M:%S')"
  echo

  echo "## Sistema"
  echo '```text'
  hostnamectl | grep -vE 'Machine ID|Boot ID'
  echo '```'
  echo

  echo "## CPU"
  echo '```text'
  LC_ALL=C lscpu | grep -E 'Architecture:|CPU\(s\):|Model name:'
  echo '```'
  echo

  echo "## Memoria"
  echo '```text'
  free -h
  echo '```'
  echo

  echo "## Discos"
  echo '```text'
  lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
  echo '```'
  echo

  echo "## Red"
  echo '```text'
  ip -br addr
  echo '```'
  echo

  echo "## Tailscale"
  echo '```text'
  tailscale status
  echo
  echo "IP Tailscale:"
  tailscale ip -4
  echo '```'
  echo

  echo "## Docker"
  echo '```text'
  echo -n "Docker: "
  docker version --format '{{.Server.Version}}' 2>/dev/null || echo "No disponible"

  echo -n "Docker Compose: "
  docker compose version 2>/dev/null || echo "No disponible"
  echo '```'

} > "$OUTPUT"

echo "Inventario generado: $OUTPUT"
