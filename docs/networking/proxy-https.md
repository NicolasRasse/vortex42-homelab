# Reverse proxy y HTTPS local

## Nginx Proxy Manager

El Compose de `docker/nginx-proxy-manager/` declara el contenedor `nginx-proxy-manager`, imagen `jc21/nginx-proxy-manager:latest`, puertos 80/81/443 y dos volúmenes:

| Destino | Finalidad | Backup |
|---|---|---|
| `/data` | Configuración y estado de NPM | Backup general |
| `/etc/letsencrypt` | Material de certificados | Bloque separado del backup general |

Homepage enlaza el panel por HTTP en `nginx.vortex42.local:81`. Las aplicaciones se enlazan mayormente por HTTPS. Las reglas reales de Proxy Hosts, opciones WebSocket, listas de acceso y certificados se almacenan fuera del Compose y no están exportadas en el ZIP.

## Flujo esperado

Cliente → resolución DNS → NPM en 443 → backend y puerto configurado → respuesta. El certificado debe cubrir el nombre utilizado y ser confiable para el cliente. El HTTPS del navegador al proxy no demuestra que la conexión del proxy al backend use HTTPS.

No hay evidencia para identificar autoridad certificadora, método de emisión, renovación o distribución de confianza. El nombre del volumen `npm_letsencrypt` tampoco lo demuestra. No asumir emisión pública para los nombres `.local`.

## Registrar o reconstruir una regla

1. Recuperar de la configuración privada el nombre, protocolo y dirección/puerto del backend.
2. Verificar conectividad **desde NPM** al backend. `localhost` dentro de NPM se refiere al propio contenedor.
3. Restaurar/importar el certificado por un canal privado y configurar su cadena según el método existente.
4. Aplicar las opciones que requiera el servicio y las restricciones de acceso existentes.
5. Probar la URL completa desde LAN y desde el cliente remoto autorizado; revisar autenticación y operaciones reales.

Los proyectos Compose no declaran una red Docker externa compartida. No asumir que NPM resuelve todos los nombres de contenedor entre proyectos. Homepage usa backends por dirección de host; los upstreams reales de NPM deben comprobarse.

## Fallos comunes

| Síntoma | Revisar |
|---|---|
| No resuelve el nombre | DNS del cliente y registro local |
| Conexión rechazada o agotada | NPM, ruta, firewall y puertos |
| Error de certificado | Nombre, fecha del sistema, caducidad, cadena y confianza |
| 502/504 | Backend, protocolo, puerto y red desde NPM |
| Página funciona pero una integración falla | URL interna, credenciales, confianza y configuración específica |

No desactivar validación TLS para ocultar un problema de confianza. El script de Vaultwarden usa este camino HTTPS para ntfy y puede perder sus avisos si falla DNS, NPM o la confianza del certificado.

## Recuperación

Restaurar `/data` y `/etc/letsencrypt` a partir de copias compatibles. El script los captura en paradas separadas, por lo que no garantiza una instantánea conjunta. No cambiar reglas/certificados durante el backup. Ver [recuperación](../operacion/recuperacion.md).
