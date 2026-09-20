# Backups y notificaciones ntfy

## Implementación actual

Fuente: los dos scripts de `scripts/backup/` del ZIP. Ambos se ejecutan en `vortex42-server`, usan una clave SSH dedicada de la cuenta operadora y transfieren a `pi5-nube:/srv/backups`. El nombre de archivo incluye fecha y hora del host. No hay cifrado del archivo declarado: SSH protege el transporte, pero el `.tar.gz` almacenado contiene datos recuperables por quien pueda leerlo.

| Script | Temporal local | Retención declarada | Avisos |
|---|---|---|---|
| `server-services-backup.sh` | `/tmp/vortex42-backups` | `RETENTION=14` | ntfy por HTTP a loopback, puerto 8083 |
| `vaultwarden-backup.sh` | `/tmp/vaultwarden-backup` | `RETENTION_DAYS=14` | ntfy por HTTPS a `ntfy.vortex42.local` |

No hay cron ni timer incluido. **Frecuencia, horario, zona horaria efectiva y última ejecución están pendientes de verificar.** Retención no equivale a frecuencia ni a número de copias.

## Cobertura del backup general

Cada fila de volumen se detecta por contenedor y destino del montaje, no por un nombre de volumen fijo. Los archivos se llaman `<prefijo>_<fecha-hora>.tar.gz`.

| Origen | Montaje / contenido | Subcarpeta en `/srv/backups` | Prefijo |
|---|---|---|---|
| portainer | `/data` | `portainer` | `portainer` |
| uptime-kuma | `/app/data` | `uptime-kuma` | `uptime-kuma` |
| nginx-proxy-manager | `/data` | `nginx-proxy-manager` | `nginx-proxy-manager` |
| actual-budget | `/data` | `actual-budget` | `actual-budget` |
| gitea | `/data` | `gitea` | `gitea` |
| filebrowser | `/database` | `filebrowser-db` | `filebrowser-db` |
| filebrowser | `/config` | `filebrowser-config` | `filebrowser-config` |
| ntfy | `/etc/ntfy` | `ntfy-config` | `ntfy-config` |
| ntfy | `/var/cache/ntfy` | `ntfy-cache` | `ntfy-cache` |
| nginx-proxy-manager | `/etc/letsencrypt` | `nginx-proxy-manager` | `npm-certificates` |
| Homepage | Carpeta `docker/homepage` completa | `homepage` | `homepage` |
| Repositorio | Carpeta `~/vortex42-homelab` | `vortex42-homelab` | `vortex42-homelab` |

El archivo del repositorio excluye `.git`, `backups`, `downloads` y `temp`. No aplica `.gitignore` ni excluye `.env` de forma general. El backup de Homepage también puede contener su `.env`. Es correcto tratarlos como copias privadas, nunca como archivos publicables.

El bloque de certificados sólo se ejecuta si encuentra el volumen. Si no lo encuentra, lo omite sin declarar fallo. La función `backup_volume()` crea su subcarpeta remota antes de copiar; los bloques de **Homepage y repositorio requieren sus carpetas remotas previamente creadas**. La carpeta de NPM ya habrá sido creada por el backup de `/data` si ese paso finalizó.

## Secuencia y consistencia

1. Comprueba SSH a `pi5-nube` antes de detener los servicios.
2. Detecta cada volumen, detiene su contenedor y lo comprime usando un contenedor `alpine` temporal.
3. Reinicia el contenedor, crea la carpeta remota correspondiente y copia el archivo.
4. Elimina el temporal local después de copiarlo.
5. Copia certificados, Homepage y repositorio; aplica retención remota y envía aviso de éxito.

La parada genera una interrupción breve por cada volumen. File Browser, ntfy y NPM se detienen más de una vez: sus archivos se capturan en momentos distintos. No es una instantánea atómica entre volúmenes o servicios. Homepage y repositorio se archivan sin detener cambios en sus archivos.

`trap cleanup EXIT` intenta reiniciar el contenedor registrado si ocurre una salida durante la operación. No garantiza recuperación tras corte eléctrico, terminación forzada o fallo de Docker, ni preserva necesariamente un servicio que estaba detenido intencionalmente. No hay bloqueo contra ejecuciones simultáneas.

## Vaultwarden

Detecta `/data`, comprueba SSH y crea `/srv/backups/vaultwarden`. Después registra la limpieza de salida, detiene Vaultwarden, comprime el volumen con `alpine`, reinicia y copia `vaultwarden_<fecha-hora>.tar.gz`. Elimina el temporal, aplica retención propia, consulta el archivo remoto y notifica éxito.

El `cleanup` intenta iniciar Vaultwarden si no está corriendo durante la sección protegida. Después del arranque normal se desactiva ese trap. Una salida explícita al no encontrar el volumen ocurre antes de esa protección y no pasa por `ERR`.

## Retención real

- General: `find` recorre **todo `/srv/backups`** y borra archivos `*.tar.gz` que coincidan con `-mtime +14`, incluyendo carpetas de otros servicios y Vaultwarden.
- Vaultwarden: limita la búsqueda a su carpeta y a `vaultwarden_*.tar.gz`.
- `-mtime +14` compara la antigüedad de modificación en períodos completos de 24 horas; no significa conservar exactamente 14 archivos ni borrar al cumplirse exactamente 14 días.
- No hay protección declarada de una última copia válida, manifiesto de ejecución, validación de integridad ni comprobación de restauración antes de eliminar copias antiguas.

Antes de usar el script general, revisar que el árbol remoto no contenga archivos que deban tener otra retención. No ejecutar la retención como prueba de diagnóstico.

## ntfy: éxito y fallo

Los dos scripts usan `curl -fsS`, título, prioridad y cuerpo breve. Éxito usa prioridad 3; error usa prioridad 5 e incluye código de salida. El tema concreto se mantiene en la configuración privada existente y no se reproduce aquí.

La función termina con `|| true`: un fallo de red, HTTP o TLS al publicar no cambia el resultado del backup. No se declaran credenciales de publicación en esos comandos ni tiempo máximo de `curl`. Esto no prueba la política real del servidor ntfy, que vive en su volumen.

Ambos scripts tienen `trap on_error ERR`, pero no activan herencia de `ERR` con `set -E`. En particular, los errores dentro de funciones o ciertas salidas explícitas pueden abortar sin pasar por ese manejador. **No todos los fallos están garantizados como alerta.** El backup general depende de ntfy local; Vaultwarden depende además de DNS, NPM y confianza TLS.

## Qué no queda cubierto

- Biblioteca y base de datos de Immich; configuración/datos de Pi-hole.
- Archivos de `/home/vortex42` fuera de la carpeta del repositorio, aunque se vean en File Browser.
- Configuración del sistema operativo, router, firewall, política Tailscale y claves SSH fuera del repositorio.
- Base externa de Gitea u otras dependencias externas, si existen.
- Logs históricos de Docker y estado de memoria de procesos.
- Pérdida de `pi5-nube`, su disco o todo el sitio; no hay copia externa declarada.

## Operación y verificación

Antes de una ejecución: comprobar montaje y espacio del destino, SSH no interactivo, directorios de Homepage/repositorio, Docker, `alpine` disponible, `tar`, `curl`, permisos y ausencia de otra ejecución. La cuenta efectiva debe tener su repositorio y clave correctos; cambiar a root modifica `$HOME`.

En una ventana de mantenimiento, sabiendo que se detendrán servicios y se aplicará retención:

```bash
cd ~/vortex42-homelab
bash -n scripts/backup/server-services-backup.sh
bash -n scripts/backup/vaultwarden-backup.sh
bash scripts/backup/server-services-backup.sh
bash scripts/backup/vaultwarden-backup.sh
```

La comprobación `bash -n` sólo valida sintaxis. Ejecutar ambos de forma secuencial, sin actualizaciones ni cambios de datos/configuración simultáneos. Comprobar salida de cada uno antes de continuar.

Después: verificar servicios iniciados, todos los archivos esperados de esa ejecución, tamaño razonable, legibilidad del archivo, entrega al suscriptor ntfy y una restauración aislada periódica. La ausencia de aviso requiere revisar el registro del trabajo y el canal ntfy por separado. No asumir que un aviso general implica éxito del script separado de Vaultwarden.

## Mejoras pendientes

Ver [roadmap](../roadmap.md): programación versionada, bloqueo de concurrencia, manejo fiable de errores, autenticación/tiempos de espera ntfy, retención acotada, manifiestos y sumas, cifrado en reposo, copia externa y ensayos de restauración.
