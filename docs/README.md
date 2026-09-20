# Documentación del homelab

## Cómo interpretar esta documentación

Fecha de revisión: 2026-09-13. Fuente principal: copia del repositorio entregada como ZIP. La conversación previa aporta contexto, pero los scripts y Compose determinan el comportamiento descrito cuando están disponibles.

- **Declarado:** visible en un archivo del repositorio; puede diferir del despliegue real.
- **Histórico:** registrado en documentación o inventario anterior, sin comprobación actual.
- **Pendiente:** no existe evidencia suficiente en esta copia.
- **Propuesto:** mejora futura, no configuración desplegada.

No se ejecutaron comandos en los hosts ni se validó una restauración. Se omiten direcciones IP de los equipos, identidad de cuenta, sufijo privado de la tailnet y valores de secretos. Los nombres de hosts, servicios y dominios locales se conservan para facilitar la operación.

## Lectura recomendada

1. [Arquitectura](arquitectura.md) y [hosts](hosts.md).
2. [Red/DNS](networking/red-dns.md), [Tailscale](networking/tailscale.md) y [HTTPS](networking/proxy-https.md).
3. [Servicios Docker](servicios-docker.md) y [monitoreo](operacion/monitoreo.md).
4. [Backups](operacion/backups.md), [recuperación](operacion/recuperacion.md) y [mantenimiento](operacion/mantenimiento.md).
5. [Seguridad](seguridad.md), [estructura](estructura-repositorio.md) y [roadmap](roadmap.md).

## Fuentes y límites

| Fuente | Qué permite documentar | Qué no demuestra |
|---|---|---|
| `docker/*/compose.yml` | Imágenes, puertos, montajes y opciones declaradas | Versión ejecutada, salud y configuración interna |
| `docker/homepage/config/` | Enlaces y widgets existentes | Monitores de Kuma ni altas nuevas en NPM |
| `scripts/backup/` | Archivos incluidos y secuencia de backup | Frecuencia, ejecución exitosa o restaurabilidad |
| `inventory/vortex42-server.md` original | Hardware y software registrados el 2026-09-05 | Estado actual de los tres hosts |
| `docs/networking/tailscale.md` original | Roles y configuración histórica | Estado actual de rutas, permisos y clientes |

## Registro de discrepancias

| Hallazgo | Tratamiento documental |
|---|---|
| README truncado y referencia a renombrar las Raspberry Pi | README reconstruido; se mantienen los nombres solicitados |
| Tailscale afirma que el servidor no anuncia rutas y luego que sí | Ambas afirmaciones se registran como conflicto pendiente |
| Bloques Markdown sin cerrar en README/Tailscale | Estructura reemplazada y enlaces revisados |
| Vaultwarden declara `flase` | Hallazgo de seguridad; no se afirma que los registros estén deshabilitados |
| Faltan Compose de Immich, Pi-hole y Portainer Agent | Servicios históricos con configuración pendiente |
| Backups sin programación versionada | Retención documentada; frecuencia no confirmada |

Las verificaciones operativas deben registrarse con fecha, host, responsable y resultado sanitizado, sin copiar salidas completas con datos privados.
