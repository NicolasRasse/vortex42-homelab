# Monitoreo y diagnóstico

## Herramientas actuales

| Herramienta | Uso | Límite conocido |
|---|---|---|
| Homepage | Accesos, `siteMonitor` y widgets | No hay enlace/configuración de los seis servicios nuevos |
| Uptime Kuma | Disponibilidad; página `homelab` referenciada | Monitores, intervalos y alertas no exportados |
| Glances | CPU, memoria, discos y procesos | Configuración sin almacenamiento histórico declarado |
| Dozzle | Consulta de logs Docker | No constituye archivo histórico independiente |
| ntfy | Avisos de backup | Entrega de mejor esfuerzo; depende del servidor principal |
| Portainer | Inspección y administración de contenedores | Estado “running” no prueba salud funcional |

Homepage usa `siteMonitor` para las seis entradas actuales. Sus widgets consultan los backends configurados; la caída de un widget puede ser causada por credenciales o confianza aunque la aplicación responda. El widget `resources` está etiquetado Homepage: no asumir que representa todo el host como Glances.

## Ronda operativa propuesta

La siguiente rutina es recomendada, no una tarea programada incluida en el repositorio:

1. Confirmar disponibilidad de los tres hosts y espacio de datos/backups.
2. Revisar servicios de usuario y monitores de Kuma.
3. Revisar fecha y cobertura de la última copia de cada script, no sólo la última alerta.
4. Inspeccionar errores persistentes en Dozzle o logs locales.
5. Verificar vencimiento de certificados y acceso remoto en revisiones periódicas.

## Diagnóstico de un servicio

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
docker logs --tail=100 ntfy
docker stats --no-stream
```

Usar el nombre del contenedor afectado y examinar las salidas localmente. No publicar logs con datos de aplicaciones, cabeceras de autenticación o rutas privadas.

| Síntoma | Comprobación siguiente |
|---|---|
| Todo el portal falla | Host, DNS y NPM antes de cada aplicación |
| Sólo un servicio falla | Contenedor, recursos, volumen y backend |
| No llega alerta de backup | Registro del trabajo, archivo remoto, `curl`, ntfy y suscripción |
| Crece uso de disco | Datos, logs, temporales fallidos y retención remota |
| Corte breve durante backup | Comparar con la ventana de parada por volumen |

## Alertas pendientes de implementar/verificar

Vigilar desde otro host la caída de `vortex42-server`, antigüedad de backups, disco lleno, servicio detenido y expiración de certificados. Probar una alerta de fallo controlada y su recuperación. No existe evidencia de integración Kuma → ntfy; no se declara como activa.
