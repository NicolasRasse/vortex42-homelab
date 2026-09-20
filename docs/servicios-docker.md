# Servicios Docker

## Convenciones

Cada carpeta tiene su propio `compose.yml`; todos los stacks incluidos declaran `restart: unless-stopped`. La tabla muestra puertos **host → contenedor**, no URLs públicas. Se omiten direcciones de los equipos. Los nombres de volúmenes son claves lógicas del Compose: Docker puede anteponer el nombre del proyecto. Confirmar el montaje efectivo antes de restaurar.

## Inventario del servidor principal

| Servicio / carpeta | Imagen declarada | Puertos TCP | Persistencia / montajes |
|---|---|---|---|
| Portainer / `portainer` | `portainer/portainer-ce:latest` | 9443→9443, 8000→8000, 9000→9000 | `portainer_data:/data`; socket Docker |
| Homepage / `homepage` | `ghcr.io/gethomepage/homepage:latest` | 3000→3000 | `./config:/app/config`; socket Docker `ro`; `.env` |
| Uptime Kuma / `uptime-kuma` | `louislam/uptime-kuma:1` | 3001→3001 | `uptime_kuma_data:/app/data` |
| Nginx Proxy Manager / `nginx-proxy-manager` | `jc21/nginx-proxy-manager:latest` | 80→80, 81→81, 443→443 | `npm_data:/data`, `npm_letsencrypt:/etc/letsencrypt` |
| Vaultwarden / `vaultwarden` | `vaultwarden/server:latest` | 8082→80 | `vaultwarden_data:/data` |
| Glances / `glances` | `nicolargo/glances:latest-full` | 61208→61208 | Socket Docker `ro`; raíz del host en `/host:ro`; `pid: host` |
| Dozzle / `dozzle` | `amir20/dozzle:latest` | 8080→8080 | Socket Docker `ro`; sin volumen de datos declarado |
| Actual Budget / `actual-budget` | `actualbudget/actual-server:latest` | 5006→5006 | `actual_data:/data` |
| Gitea / `gitea` | `gitea/gitea:latest` | 3002→3000, 2222→22 | `gitea_data:/data` |
| File Browser / `filebrowser` | `filebrowser/filebrowser:latest` | 8081→80 | `/home/vortex42:/srv`, `filebrowser_db:/database`, `filebrowser_config:/config` |
| ntfy / `ntfy` | `binwiederhier/ntfy:latest` | 8083→80 | `ntfy_cache:/var/cache/ntfy`, `ntfy_config:/etc/ntfy` |

El nombre del contenedor coincide con la carpeta en estos stacks. Las claves de servicio Compose que difieren son `actual` en Actual Budget y `npm` en Nginx Proxy Manager. Los comandos Compose aceptan la clave de servicio; `docker inspect` acepta el nombre del contenedor.

## Fichas de operación

### Portainer

Administra Docker mediante su socket local. Homepage dispone de enlace y widget. El backup general copia `/data`. La conexión a agentes remotos y los endpoints registrados viven en la configuración interna; el repositorio no permite reconstruirlos manualmente. Probar login y acceso a los endpoints después de restaurar. Los puertos adicionales publicados deben revisarse según su uso efectivo.

### Homepage

Panel del homelab con grupos Infraestructura y Servicios. Incluye Portainer, Uptime Kuma, NPM, Pi-hole, Immich y Vaultwarden. Los seis servicios nuevos no están añadidos en el `services.yaml` entregado.

Los widgets usan referencias `HOMEPAGE_VAR_PORTAINER_KEY`, `HOMEPAGE_VAR_NPM_USERNAME`, `HOMEPAGE_VAR_NPM_PASSWORD`, `HOMEPAGE_VAR_PIHOLE_KEY` y `HOMEPAGE_VAR_IMMICH_KEY`. Sus valores van en el `.env` privado del stack. `HOMEPAGE_ALLOWED_HOSTS` restringe los nombres aceptados por la aplicación; no sustituye autenticación ni firewall. `docker.yaml` contiene ejemplos comentados, por lo que montar el socket no demuestra una integración Docker configurada.

El backup copia la carpeta completa de Homepage, incluido su `.env` si existe. Restaurar los archivos privados fuera de Git y comprobar enlaces, widgets y hosts permitidos.

### Uptime Kuma

Monitoreo de disponibilidad con datos en `/app/data`, cubiertos por backup general. Homepage usa el slug de página de estado `homelab`. No hay exportación de monitores, intervalos, usuarios o destinos de alertas. Tras restaurar, comprobar monitores, página de estado y entrega real de notificaciones.

### Nginx Proxy Manager

Entrada HTTP/HTTPS y panel administrativo. Requiere ambos volúmenes para una recuperación completa del estado respaldado. Consultar [HTTPS](networking/proxy-https.md) para dependencias de DNS, confianza y upstreams.

### Vaultwarden

Gestor de contraseñas con `/data` respaldado por su script específico. `DOMAIN` apunta a `https://vault.vortex42.local`. El valor `SIGNUPS_ALLOWED: "flase"` está mal escrito: no considerar confirmada la prohibición de registros. Corregirlo y validar la política efectiva en un cambio operativo aparte. Tras restaurar, probar acceso y sincronización con una cuenta autorizada, sin volcar información de la bóveda en logs o documentación.

### Glances

Métricas del sistema en modo web (`GLANCES_OPT=-w`). Accede a procesos del host, su sistema de archivos en lectura y socket Docker. No declara datos persistentes; recuperar mediante Compose, conservando versión y configuración. No se ha comprobado autenticación en ejecución. Verificar métricas y restringir el acceso a operadores.

### Dozzle

Consulta de logs Docker mediante socket. No declara almacenamiento propio ni archivo histórico de logs: recuperar el Compose no recupera logs eliminados del motor Docker. Restringir acceso porque los logs pueden contener información privada.

### Actual Budget

Gestión de presupuestos; servicio Compose `actual`, contenedor `actual-budget`. Backup general de `/data`. Confirmar acceso y apertura de un presupuesto autorizado tras restaurar. Configuración de autenticación e integraciones financieras no está exportada; no asumir que queda reconstruida sólo por el Compose.

### Gitea

Git por web y SSH. El SSH de Gitea se publica en 2222, distinto del SSH administrativo del host. Backup de `/data`. La conversación previa describe SQLite, pero el Compose no demuestra qué base está configurada; verificar la configuración privada antes de confiar en esa cobertura. Si existiera una base externa, necesita su propio respaldo. Validar login, clonación de un repositorio de prueba y la URL/puerto SSH correctos.

### File Browser

Explora `/home/vortex42` a través de `/srv` dentro del contenedor. Ese bind mount es de lectura/escritura según el Compose. El backup general copia únicamente `/database` y `/config`; **no respalda todo `/home/vortex42`**. El archivo del repositorio sólo protege la subcarpeta incluida en él. Confirmar cobertura independiente de cualquier otro archivo administrado desde File Browser.

### ntfy

Servidor iniciado con `serve`. Su configuración y caché se respaldan en dos archivos separados. El Compose no demuestra autenticación, autorización ni retención de mensajes. Los scripts publican avisos de backup; ver [backups](operacion/backups.md). Tras restaurar, comprobar autorización de publicación/suscripción y recibir un mensaje de prueba acordado.

## Servicios de las Raspberry Pi

| Servicio | Host documentado | Evidencia / pendiente |
|---|---|---|
| Immich | pi5-nube | Homepage apunta al puerto 2283 y declara widget versión 2; faltan Compose, versión real, base, biblioteca y backup |
| Pi-hole | pi3-red | Homepage declara widget versión 6 y panel HTTP; faltan configuración DNS, persistencia y backup |
| Portainer Agent | pi3-red | Mencionado en Tailscale; faltan despliegue, puertos y configuración |

No inferir puertos, volúmenes ni versiones de despliegue a partir de valores predeterminados de esos productos. El indicador de versión de un widget no identifica una versión exacta instalada.

## Desplegar o revisar un stack

Ejemplo para ntfy, desde la copia existente y con el nombre de proyecto ya verificado:

```bash
cd ~/vortex42-homelab
docker compose -f docker/ntfy/compose.yml config --quiet
docker compose -f docker/ntfy/compose.yml ps
```

Para un despliegue autorizado, una vez recuperados configuración y volúmenes:

```bash
docker compose -f docker/ntfy/compose.yml up -d
docker compose -f docker/ntfy/compose.yml logs --tail=100
```

Revisar logs localmente antes de compartirlos. No combinar todos los Compose en una sola ejecución ni usar `down -v`: podría borrar los volúmenes necesarios para recuperar datos. Las imágenes `latest`, `latest-full` y `:1` son referencias variables; registrar digest/versión efectiva antes de actualizar.
