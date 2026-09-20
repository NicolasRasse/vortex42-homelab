# Estructura del repositorio

Estructura después de incorporar esta documentación:

```text
vortex42-homelab/
├── .gitignore
├── README.md
├── CHANGELOG.md
├── docker/
│   ├── actual-budget/compose.yml
│   ├── dozzle/compose.yml
│   ├── filebrowser/compose.yml
│   ├── gitea/compose.yml
│   ├── glances/compose.yml
│   ├── homepage/
│   │   ├── compose.yml
│   │   └── config/
│   ├── nginx-proxy-manager/compose.yml
│   ├── ntfy/compose.yml
│   ├── portainer/compose.yml
│   ├── uptime-kuma/compose.yml
│   └── vaultwarden/compose.yml
├── docs/
│   ├── README.md
│   ├── arquitectura.md
│   ├── hosts.md
│   ├── servicios-docker.md
│   ├── seguridad.md
│   ├── estructura-repositorio.md
│   ├── roadmap.md
│   ├── networking/
│   │   ├── red-dns.md
│   │   ├── tailscale.md
│   │   └── proxy-https.md
│   └── operacion/
│       ├── backups.md
│       ├── monitoreo.md
│       ├── mantenimiento.md
│       └── recuperacion.md
├── inventory/
│   └── vortex42-server.md
└── scripts/
    ├── inventory.sh
    └── backup/
        ├── server-services-backup.sh
        └── vaultwarden-backup.sh
```

El ZIP contiene **11** Compose: el de Homepage está representado dentro de su subcarpeta. No incluye `.git`, stacks de Immich/Pi-hole, cron, timers, reglas NPM ni política Tailscale. `assets/` y `templates/` aparecían en el README anterior, pero no contienen archivos en la copia recibida; no se presentan como componentes existentes.

## Responsabilidades

- `docker/`: configuración declarativa de aplicaciones. Los volúmenes en ejecución residen fuera de Git.
- `docker/homepage/config/`: enlaces, widgets, aspecto y ejemplos comentados. Los archivos `proxmox.yaml` y `kubernetes.yaml` no prueban uso de esas plataformas.
- `docs/`: arquitectura, operación, procedimientos y pendientes.
- `inventory/`: resúmenes sanitizados y fechados del hardware/software observado.
- `scripts/backup/`: implementación de copias; cualquier cambio exige revisar el documento de backups.
- `scripts/inventory.sh`: captura local que requiere revisión de privacidad antes de versionar su salida.

## Convenciones

Mantener los nombres actuales de hosts y carpetas. Escribir en español, fechar verificaciones y vincular afirmaciones a archivos o registros sanitizados. Distinguir configuración actual, observación histórica y propuesta. No documentar como activo un servicio, monitor o ruta sólo porque fue sugerido.

Al modificar un servicio, revisar su ficha, DNS/proxy si corresponde, cobertura de backups, restauración y CHANGELOG. Si falta una configuración privada necesaria, registrar su función y ubicación lógica sin copiar su contenido sensible.
