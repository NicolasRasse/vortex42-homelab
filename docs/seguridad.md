# Seguridad y manejo de secretos

## Alcance

Esta es una revisión documental del repositorio, no una auditoría del despliegue. Tailscale, HTTPS y las reglas de la aplicación cubren capas diferentes; no se infiere aislamiento efectivo a partir de una sola de ellas.

## Qué queda fuera de Git

Nunca incorporar contraseñas, tokens, claves API, claves SSH privadas, claves de certificados, `.env` reales, bases de datos, archivos de bóvedas, presupuestos, fotos, logs privados o backups. Mantener recuperación de esos elementos en un almacén privado accesible aun si Vaultwarden está caído.

`.gitignore` ya excluye muchos de esos formatos. No elimina archivos previamente rastreados ni controla qué entra en un `tar`. Excluye también `.env.*`; una futura plantilla `.env.example` requeriría revisar una excepción deliberada y usar sólo marcadores vacíos.

## Hallazgos del ZIP

| Hallazgo | Consecuencia / acción pendiente |
|---|---|
| `SIGNUPS_ALLOWED: "flase"` en Vaultwarden | Corregir a un valor válido según política y comprobar comportamiento real |
| Puertos Docker sin IP de enlace restrictiva | Revisar accesibilidad LAN/Tailscale y firewall efectivo; no asumir acceso sólo por proxy |
| Socket Docker en Portainer, Homepage, Glances y Dozzle | Acceso privilegiado al motor; `:ro` en el montaje no convierte la API en sólo lectura |
| Glances monta raíz del host y usa `pid: host` | Expone información del sistema a la aplicación |
| File Browser monta el home en escritura | Revisar alcance, permisos y acceso a archivos privados |
| Paneles NPM/Pi-hole y ciertos backends usan HTTP | Revisar red de acceso; no afirmar cifrado de extremo a extremo |
| ntfy sin credenciales en los comandos de backup | Confirmar política de publicación/suscripción; un nombre de tema no es un control de acceso |
| Imágenes con etiquetas variables | Registrar y fijar versiones/digests para reconstrucción reproducible |
| Backups contienen `.env`, bases y certificados | Proteger permisos, almacenamiento y distribución; mantenerlos fuera de Git |

No se cambió ninguno de estos comportamientos durante esta tarea de documentación.

## Acceso y cuentas

Usar cuentas administrativas individuales cuando sea posible, mínimo privilegio y políticas Tailscale limitadas a los servicios necesarios. Revisar sesiones, dispositivos y claves autorizadas. Los mecanismos MFA y restricciones existentes no están exportados, por lo que se consideran pendientes de comprobación.

La clave SSH de backups debe permanecer privada, con permisos restrictivos y acceso al destino acorde con el trabajo. Verificar la identidad del host remoto. No desactivar comprobaciones de host o certificado para que un trabajo termine.

## Revisión antes de Git

```bash
git status --short
git diff --check
git diff -- README.md docs inventory CHANGELOG.md
```

Revisar también nombres de archivo y contenido de los nuevos archivos, que no aparecen en `git diff` hasta agregarlos. Examinar el diff preparado antes del commit. Los informes generados por `scripts/inventory.sh` incluyen metadatos de red/cuenta: sanitizarlos manualmente. No incluir salidas completas de `docker inspect` o de Compose con variables resueltas.

## Si se descubre un secreto versionado

Tratarlo como comprometido, revocarlo o rotarlo en el servicio correspondiente y revisar su uso. Eliminarlo de la versión actual no elimina copias ni historial. Planificar limpieza del historial y coordinación con los clones por separado. No copiar el valor encontrado a un issue, comentario o documento.
