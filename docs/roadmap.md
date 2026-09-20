# Roadmap

Trabajo propuesto a partir de los archivos recibidos. Ningún punto de esta lista se considera desplegado por esta entrega.

## Prioridad 1: seguridad y recuperación

| Trabajo | Criterio de finalización |
|---|---|
| Corregir `SIGNUPS_ALLOWED` de Vaultwarden | Valor válido y política efectiva comprobada |
| Ensayar restauración de Vaultwarden y NPM | Datos utilizables, certificados y acceso verificados en entorno aislado |
| Verificar autenticación/exposición de paneles y ntfy | Matriz de acceso desde LAN/Tailscale y políticas documentadas |
| Revisar alcance de File Browser y sockets Docker | Permisos necesarios identificados y acceso limitado |
| Asegurar cobertura de Immich y Pi-hole | Configuraciones sanitizadas y copia/restauración de datos comprobadas |
| Proteger backups fuera de pi5-nube | Copia independiente protegida, recuperable y probada |

## Prioridad 2: fiabilidad de backups

| Trabajo | Criterio de finalización |
|---|---|
| Versionar cron/timer sanitizado | Frecuencia, horario, cuenta, entorno, logs y zona horaria documentados |
| Impedir ejecuciones simultáneas | Bloqueo probado sin dejar contenedores detenidos |
| Revisar manejo de errores y estado inicial | Fallos internos notificados y estado anterior preservado |
| Crear todos los directorios remotos | Primera ejecución funciona con destino preparado sin pasos ocultos |
| Acotar retención y proteger copia válida | Ningún archivo ajeno eliminado; política por servicio verificada |
| Añadir manifiestos e integridad | Conjunto esperado y sumas verificables antes de rotar |
| Asegurar consistencia multivolumen | Captura y restauración coherentes de NPM, ntfy y File Browser |
| Mejorar entrega ntfy | Autorización, timeout y fallo de entrega observables |
| Alertar por antigüedad desde otro host | Detecta trabajos que no se ejecutan y caída del servidor principal |

## Prioridad 3: reproducibilidad y red

- Resolver contradicción de rutas Tailscale y probar redundancia con acceso alternativo.
- Completar inventarios de `pi5-nube` y `pi3-red`, incluyendo discos y montajes.
- Exportar/configurar de forma sanitizada DNS, NPM y servicios faltantes.
- Registrar emisión, renovación y confianza de HTTPS local.
- Fijar versiones/digests y documentar migraciones por servicio.
- Añadir Glances, Dozzle, Actual Budget, Gitea, File Browser y ntfy a Homepage con destinos verificados.
- Registrar monitores y canales de alertas de Kuma; no asumir integración ntfy existente.
- Revisar el generador de inventario para producir una salida publicable por defecto.

## Prioridad 4: objetivos operativos

Definir RPO y RTO por servicio, medir duración y tamaño de copias, planificar capacidad, establecer calendario de ensayos y registrar resultados. Evaluar cambios de dominio local o distribución de servicios sólo después de estabilizar recuperación y monitoreo.
