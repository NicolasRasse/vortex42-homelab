# Vortex42 Homelab

Configuración y documentación del homelab Vortex42: servicios Docker, red privada, acceso remoto, monitoreo y recuperación.

## Alcance y estado
Este repositorio documenta y versiona la infraestructura actual del homelab Vortex42. Incluye configuraciones Docker, red, acceso remoto, monitoreo, backups, procedimientos de mantenimiento y recuperación.

Los nodos principales son **vortex42-server**, **pi5-nube** y **pi3-red**.

| Host | Función documentada | Evidencia disponible |
|---|---|---|
| vortex42-server | Servidor Docker principal; origen de backups | Inventario histórico, 11 archivos Compose y scripts |
| pi5-nube | Immich y destino de backups | README anterior, Homepage y scripts; falta configuración del host |
| pi3-red | Pi-hole, red y acceso remoto | Documentación Tailscale y Homepage; falta configuración del host |

El servidor principal dispone de Portainer, Homepage, Uptime Kuma, Nginx Proxy Manager, Vaultwarden, Glances, Dozzle, Actual Budget, Gitea, File Browser y ntfy. Immich y Pi-hole forman parte del homelab, pero sus stacks no están incluidos en esta copia.

## Mapa de documentación

| Documento | Contenido |
|---|---|
| [Índice y evidencia](docs/README.md) | Fuentes, estado declarado y pendientes |
| [Arquitectura](docs/arquitectura.md) | Nodos, flujos y dependencias |
| [Inventario de hosts](docs/hosts.md) | Hardware conocido, funciones y datos faltantes |
| [Red y DNS](docs/networking/red-dns.md) | DNS local, puertos y resolución |
| [Tailscale y acceso remoto](docs/networking/tailscale.md) | MagicDNS, rutas, Exit Node y diagnóstico |
| [Reverse proxy y HTTPS](docs/networking/proxy-https.md) | Nginx Proxy Manager, certificados y confianza |
| [Servicios Docker](docs/servicios-docker.md) | Inventario, persistencia y operación por servicio |
| [Backups y ntfy](docs/operacion/backups.md) | Cobertura exacta, retención, dependencias y límites |
| [Monitoreo](docs/operacion/monitoreo.md) | Homepage, Kuma, Glances, Dozzle y alertas |
| [Seguridad](docs/seguridad.md) | Secretos, permisos, exposición y hallazgos |
| [Recuperación](docs/operacion/recuperacion.md) | Orden de recuperación y restauración de datos |
| [Mantenimiento](docs/operacion/mantenimiento.md) | Cambios, diagnóstico y actualización |
| [Estructura del repositorio](docs/estructura-repositorio.md) | Archivos, convenciones y contribuciones |
| [Roadmap](docs/roadmap.md) | Trabajo pendiente por prioridad |

## Operación inicial

En `vortex42-server`, desde la copia existente:

```bash
cd ~/vortex42-homelab
git status --short
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

Consultar la ficha del servicio antes de desplegarlo. Cada carpeta `docker/<servicio>/` contiene un proyecto Compose independiente. Homepage necesita un `.env` local que no está en Git. Conservar el nombre de proyecto utilizado en producción para reutilizar los volúmenes correctos.

## Backups actuales

`scripts/backup/server-services-backup.sh` respalda los servicios generales y `scripts/backup/vaultwarden-backup.sh` respalda Vaultwarden. Ambos transfieren archivos a `pi5-nube:/srv/backups` mediante SSH/SCP y configuran retención de 14 días. Las notificaciones ntfy son de mejor esfuerzo: su fallo no hace fallar el backup. Los backups se ejecutan mediante timers de systemd configurados en los hosts. Actualmente las unit files y timers no están versionados en este repositorio, por lo que documentarlos constituye una tarea pendiente.

Ver [cobertura y limitaciones](docs/operacion/backups.md) antes de considerar recuperable un servicio. Los backups contienen datos privados y pueden incluir credenciales; no deben incorporarse a Git.

## Pendientes importantes

- Revisar el valor mal escrito `SIGNUPS_ALLOWED: "flase"` de Vaultwarden y comprobar la política efectiva.
- Confirmar las rutas Tailscale anunciadas por `vortex42-server`: el documento anterior contenía afirmaciones contradictorias.
- Versionar configuraciones sanitizadas y procedimientos de backup de Immich y Pi-hole.
- Verificar restauraciones, entrega de alertas, programación de backups y copia fuera de `pi5-nube`.

Esta revisión modifica documentación; no cambia servicios, scripts, credenciales ni reglas de red.
