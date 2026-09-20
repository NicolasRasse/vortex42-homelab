# Recuperación y restauración

## Antes de comenzar

Este procedimiento es una guía de recuperación basada en los formatos de los scripts. **No se ha ejecutado una restauración en los hosts.** Los datos de Immich/Pi-hole, las versiones efectivas y la configuración privada faltante requieren procedimientos adicionales.

1. Identificar alcance del incidente y detener escrituras del servicio afectado en una ventana acordada.
2. Conservar datos actuales y logs relevantes en ubicación privada; no borrar volúmenes ni sobrescribir el único backup.
3. Elegir una copia por servicio, fecha y contenido. Un fallo parcial del script puede dejar un conjunto incompleto.
4. Recuperar credenciales, claves y configuración privada por una vía independiente del servicio caído.
5. Verificar espacio, montajes, permisos, versión de aplicación y compatibilidad de la base de datos.
6. Probar en un entorno aislado antes de cambiar el servicio real. No enviar notificaciones ni conectar integraciones externas durante el ensayo.

## Orden ante pérdida del servidor principal

1. Recuperar sistema operativo, usuario operador, almacenamiento y red básica de `vortex42-server`.
2. Restablecer acceso administrativo y resolución para alcanzar `pi5-nube`; verificar identidad del destino.
3. Obtener el repositorio y configuración privada; instalar versiones compatibles de Docker/Compose según el inventario real conservado.
4. Recuperar datos de NPM y certificados; validar DNS y confianza para los dominios existentes.
5. Recuperar Vaultwarden y comprobar acceso/sincronización.
6. Recuperar Actual Budget, Gitea y File Browser con todos sus archivos necesarios.
7. Recuperar ntfy, Uptime Kuma, Portainer y Homepage; validar sus configuraciones internas.
8. Recrear Glances y Dozzle desde configuración y versión registradas.
9. Comprobar acceso de usuarios desde LAN/Tailscale; ejecutar y verificar un nuevo backup antes de cerrar el incidente.

El orden puede ajustarse si un servicio aporta el acceso necesario para otro. No depender únicamente de Portainer para recuperar Docker. Si la caída también afecta a Pi-hole, recuperar DNS o utilizar un mecanismo temporal privado de resolución documentado antes de evaluar HTTPS.

## Comprobar un archivo

En una máquina de recuperación autorizada, copiar el backup a una carpeta privada. Sustituir el marcador por la ruta real; no usar estas instrucciones sobre un archivo desconocido:

```bash
ARCHIVO='/ruta/privada/copia.tar.gz'
test -f "$ARCHIVO" || exit 1
gzip -t "$ARCHIVO"
tar -tzf "$ARCHIVO"
sha256sum "$ARCHIVO"
```

Comprobar cada resultado por separado y detenerse ante error. `gzip -t` detecta daños de compresión; listar permite inspeccionar contenido y rutas. Una suma calculada ahora sólo permite comparar copias posteriores: los scripts actuales no generan un manifiesto con el que verificar autenticidad o completitud. No extraer archivos con rutas absolutas o componentes `..` inesperados.

## Restaurar un volumen en un entorno de prueba

Los archivos de volúmenes contienen el contenido de su montaje en la raíz del archivo (`tar -C /source .` o equivalente). No incluyen la definición del volumen Docker.

1. Usar un motor Docker de prueba separado del de producción, con imagen de aplicación y herramienta de extracción conocidas y compatibles.
2. Inspeccionar el archivo como en la sección anterior.
3. Crear **un volumen nuevo y vacío**; confirmar que su nombre no existe antes de crearlo.
4. Extraer con el backup montado en lectura, preservando propietarios/permisos, y sin arrancar aún la aplicación.

Ejemplo orientativo para un solo volumen, con rutas y nombre elegidos por el operador:

```bash
ARCHIVO='/ruta/privada/copia.tar.gz'
VOLUMEN_NUEVO='restauracion-prueba-servicio'
test -f "$ARCHIVO" || exit 1
if docker volume inspect "$VOLUMEN_NUEVO" >/dev/null 2>&1; then
  echo 'El volumen ya existe; elegir otro nombre y revisar.'
  exit 1
fi
docker volume create "$VOLUMEN_NUEVO" || exit 1
docker run --rm --network none \
  --mount "type=bind,src=${ARCHIVO},dst=/backup/copia.tar.gz,readonly" \
  --mount "type=volume,src=${VOLUMEN_NUEVO},dst=/restore" \
  alpine tar -xzpf /backup/copia.tar.gz -C /restore
```

Usar una imagen `alpine` local previamente verificada; registrar su versión para repetir el ensayo. La extracción escribe sólo en el volumen nuevo. Comprobar su resultado antes de continuar.

Preparar un Compose privado de prueba que monte ese volumen mediante `external: true` y su nombre exacto. Mantener el destino del montaje original, ajustar nombres de contenedores y puertos para evitar colisiones, deshabilitar integraciones y validar con `config --quiet`. No arrancar los Compose originales sin verificar qué volumen seleccionan.

## Conjuntos que deben recuperarse juntos

| Servicio | Datos necesarios | Validación funcional |
|---|---|---|
| Vaultwarden | Volumen `/data`, Compose y configuración de acceso/TLS | Login y sincronización con cuenta autorizada |
| NPM | `/data` y `/etc/letsencrypt` compatibles | Reglas, certificados y acceso a cada backend |
| Portainer | `/data` y acceso al motor/endpoints | Login y endpoints esperados |
| Uptime Kuma | `/app/data` | Monitores, página y avisos |
| Actual Budget | `/data` y configuración privada | Abrir un presupuesto autorizado |
| Gitea | `/data`; base externa si corresponde | Login y clonación de repositorio de prueba |
| File Browser | `/database`, `/config` y datos reales del bind mount | Permisos, navegación y archivo de prueba |
| ntfy | `/etc/ntfy` y `/var/cache/ntfy` | Autorización, publicación y recepción de prueba |
| Homepage | Carpeta `homepage`, `.env` privado | Enlaces, widgets y hosts permitidos |
| Glances / Dozzle | Compose y versión registrada | Métricas/logs esperados sin acceso excesivo |

Los backups separados de NPM, File Browser y ntfy no garantizan coherencia entre sí. Seleccionar el mismo conjunto temporal, revisar si hubo cambios entre capturas y validar antes de activar el servicio.

## Homepage y repositorio

El archivo de Homepage incluye una carpeta superior `homepage/`. El del repositorio incluye `vortex42-homelab/` y excluye `.git`. Extraer ambos a un directorio privado nuevo, revisar diferencias y recuperar sólo los archivos necesarios. No extraer directamente sobre la copia activa ni agregar los `.env` recuperados a Git.

Para restaurar el repositorio, obtener primero un clon Git conocido si está disponible y comparar con la copia del backup. El archivo sin `.git` no restaura historial ni ramas. Recuperar configuraciones privadas por separado y mantener los nombres de proyecto Compose originales cuando corresponda.

## Pérdida de pi5-nube o pi3-red

**pi5-nube:** afecta a Immich y al destino de backups. Si se pierde el almacenamiento de las copias y no existe otra copia, este repositorio no permite recuperar esos datos. Recuperar host y almacenamiento, verificar montaje/permisos de `/srv/backups` y luego restaurar desde una copia independiente. Immich necesita biblioteca y base compatibles; no iniciar una biblioteca vacía sobre rutas de datos sin verificar su despliegue.

**pi3-red:** recuperar sistema, Pi-hole y su configuración DNS, luego Tailscale y funciones de ruta autorizadas. El ZIP no contiene los archivos necesarios para automatizar esa recuperación. No afirmar continuidad por un router redundante hasta resolver la contradicción documental.

## Paso a producción y vuelta atrás

Tras un ensayo satisfactorio, acordar interrupción, detener el servicio y conservar su volumen anterior. Cambiar explícitamente el montaje al conjunto restaurado, arrancar con versión compatible y repetir verificaciones. Mantener el volumen anterior hasta cerrar la validación.

Si falla, detener el servicio nuevo y volver al conjunto anterior sólo si su versión y formato siguen siendo compatibles. Cambiar la imagen a una anterior no revierte una migración de base de datos. Evitar escrituras simultáneas sobre ambas copias.

## Criterio de cierre

Servicio funcional, permisos correctos, datos esperados, DNS/TLS/acceso remoto verificados y nuevo backup probado. Registrar copia usada, versión, tiempos reales, pérdida observada, pruebas y problemas. No hay RPO/RTO medidos en el repositorio; definir objetivos y compararlos con estos ensayos.
