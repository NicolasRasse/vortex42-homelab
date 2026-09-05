# Vortex42 Homelab

Repositorio de configuración, documentación e infraestructura del homelab Vortex42.

## Objetivos

- Mantener documentada la infraestructura.
- Versionar configuraciones y scripts.
- Facilitar la recuperación y reconstrucción de los servidores.
- Centralizar la documentación de Docker, Tailscale, red, seguridad y backups.
- Evitar depender de configuraciones realizadas manualmente y no documentadas.

## Infraestructura

| Equipo | Rol | Sistema | Estado |
|---|---|---|---|
| vortex42-server | Servidor principal / Docker | Debian 13 | Activo |
| pi5-nube | Immich y servicios dedicados | Raspberry Pi | Activo |
| pi3-red | Infraestructura ligera / red | Raspberry Pi | Activo |

> Los nombres de las Raspberry Pi serán normalizados posteriormente al esquema `vortex42-*`.

## Estructura

```text
vortex42-homelab/
├── assets/
├── docker/
├── docs/
├── inventory/
├── scripts/
└── templates/
