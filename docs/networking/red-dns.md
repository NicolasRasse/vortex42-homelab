# Red y DNS

## Dominios y responsabilidades

El homelab utiliza nombres bajo `vortex42.local`. Pi-hole es el servicio DNS local documentado; MagicDNS resuelve los nombres de equipos dentro de Tailscale. Son funciones distintas: resolver `pi5-nube` no garantiza resolver `immich.vortex42.local`.

Las direcciones concretas se consultan en la configuración privada existente. Homepage contiene backends por IP: un cambio de dirección requiere revisar widgets y upstreams, además del DNS.

## Nombres existentes

| Nombre | Evidencia en el repositorio |
|---|---|
| `homepage.vortex42.local` | Hosts permitidos de Homepage |
| `portainer.vortex42.local` | Enlace HTTPS en Homepage |
| `uptime.vortex42.local` | Enlace HTTPS en Homepage |
| `nginx.vortex42.local:81` | Panel NPM por HTTP en Homepage |
| `pihole.vortex42.local/admin` | Panel Pi-hole por HTTP en Homepage |
| `immich.vortex42.local` | Enlace HTTPS en Homepage |
| `vault.vortex42.local` | Enlace HTTPS y `DOMAIN` de Vaultwarden |
| `ntfy.vortex42.local` | Destino HTTPS del script de Vaultwarden |

No hay exportación de registros Pi-hole ni de reglas NPM. Estos nombres evidencian intención/configuración de clientes, no resolución o certificados comprobados. No se inventan dominios para Glances, Dozzle, Actual Budget, Gitea o File Browser.

## Comprobación por capas

En un cliente autorizado de la LAN o de Tailscale:

```bash
getent hosts vortex42-server
getent hosts vault.vortex42.local
curl --head --connect-timeout 5 https://vault.vortex42.local
```

`getent` consulta el resolvedor del sistema y puede no estar disponible en todos los clientes. Si falla un nombre, revisar DNS efectivo y sus registros antes del proxy. Si resuelve pero no conecta, revisar ruta y firewall. Si conecta con error TLS, revisar nombre, cadena y confianza. Una respuesta HTTP de autenticación puede confirmar conectividad, pero no salud funcional.

## Aspectos pendientes

- Identificar quién entrega DNS por DHCP y si existe un DNS alternativo.
- Confirmar si Pi-hole es el DNS configurado para clientes Tailscale y si estos pueden alcanzarlo.
- Revisar posibles conflictos de `.local` con mDNS en los clientes. Se preserva el dominio actual; cualquier migración requiere un plan separado.
- Registrar red LAN anunciada, rutas aprobadas y exclusiones en documentación privada.
- Revisar qué interfaces pueden alcanzar los puertos Docker. Los Compose publican puertos sin restringirlos a loopback.

El inventario completo de puertos se encuentra en [servicios Docker](../servicios-docker.md). No hay evidencia suficiente para afirmar que el router no reenvía puertos o que un firewall filtra todos los accesos.
