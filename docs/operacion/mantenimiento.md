# Mantenimiento y procedimientos habituales

## Antes de un cambio

Revisar [hallazgos](../seguridad.md), dependencias del servicio y cobertura de backup. Conservar configuración y versión efectiva, verificar una copia recuperable y definir vuelta atrás. Evitar coincidir con la parada de contenedores que realizan los scripts de backup.

```bash
cd ~/vortex42-homelab
git status --short
docker compose ls
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

No descartar cambios locales ni cambiar nombres de proyecto Compose. La carpeta y el nombre de proyecto determinan recursos como los volúmenes cuando no se declaran nombres externos explícitos.

## Actualizar un servicio

1. Registrar imagen/digest actual y leer las instrucciones de migración de la versión elegida en su documentación oficial.
2. Verificar backup de datos y configuración; no basta el Compose.
3. Ensayar la actualización cuando cambie el formato de datos o sea un servicio crítico.
4. Ajustar la referencia de imagen, validar el Compose y actualizar sólo ese stack en una ventana acordada.
5. Revisar logs, operación real, proxy y alertas; registrar resultado en CHANGELOG.

Ejemplo para ntfy después de cumplir esos pasos:

```bash
docker compose -f docker/ntfy/compose.yml config --quiet
docker compose -f docker/ntfy/compose.yml pull
docker compose -f docker/ntfy/compose.yml up -d
docker compose -f docker/ntfy/compose.yml ps
```

Comprobar el resultado de cada comando antes del siguiente. `pull` con una etiqueta variable puede traer una versión distinta. No actualizar todos los stacks en bloque sin una decisión explícita.

## Alta de un servicio

Definir host, puertos, autenticación, recursos, persistencia y nombre de proyecto. Crear Compose sin valores privados, validar el despliegue y añadir ficha de servicio. Si necesita DNS/HTTPS, registrar el nombre y proxy reales. Añadir a Homepage y monitoreo cuando proceda, y definir respaldo/restauración antes de almacenar datos importantes.

No añadir automáticamente un montaje a `backup_volume()` sin confirmar que sea un volumen nombrado y que detener ese contenedor produzca una copia consistente. Los bind mounts y bases externas requieren tratamiento propio.

## Reinicio de host

Comprobar que no haya backups/actualizaciones activos, disponer de acceso alternativo y revisar discos. Tras el reinicio confirmar Docker, montajes, Tailscale, DNS, proxy y aplicaciones. `unless-stopped` no sustituye un control de salud ni garantiza que un contenedor detenido intencionalmente se inicie.

## Espacio insuficiente

Determinar si el uso está en datos, logs, imágenes, temporales o destino de backup. Conservar evidencia y copias válidas. No ejecutar limpiezas globales de Docker ni borrados de volúmenes como primer paso. Revisar los temporales de los scripts: pueden persistir después de un fallo.

## Preparar cambios para Git

Revisar únicamente los archivos del cambio, incluidos nuevos archivos; luego:

```bash
git diff --check
git add README.md docs/ inventory/vortex42-server.md CHANGELOG.md
git diff --cached --check
git diff --cached
```

Ese `git add` corresponde a la entrega documental. Si había otros cambios dentro de esas rutas, seleccionar archivos o fragmentos individualmente. Confirmar que el índice sólo contenga lo deseado antes de crear el commit. Publicar es un paso posterior del operador.
