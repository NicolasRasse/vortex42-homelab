# Tailscale

## Objetivo

Tailscale constituye la red privada de acceso remoto del homelab Vortex42.

Permite acceder a los servidores y servicios desde fuera de la red local sin exponer directamente los servicios a Internet.

Tailscale forma parte de la infraestructura base del homelab y es independiente de las aplicaciones alojadas en los servidores.

---

## Nodos

| Hostname | IP LAN | IP Tailscale | Rol |
|---|---|---|---|
| vortex42-server | 192.168.1.117 | 100.92.205.107 | Servidor principal |
| pi3-red | 192.168.1.100 | 100.90.112.124 | Infraestructura de red |
| pi5-nube | 192.168.1.88 | 100.68.83.125 | Immich |
| redmi-note-11 | - | 100.87.128.50 | Cliente móvil |

---

## vortex42-server

Servidor principal del homelab.

Tailscale se utiliza para:

- Administración remota.
- Acceso SSH.
- Acceso privado a servicios Docker.
- Comunicación con los demás nodos del homelab.

No anuncia actualmente rutas de subnet ni funciona como Exit Node.

IP Tailscale:

`100.92.205.107`

IP LAN:

`192.168.1.117`

---

## pi3-red

Nodo dedicado principalmente a infraestructura ligera y red.

Servicios/funciones:

- Pi-hole.
- Tailscale.
- Subnet Router.
- Exit Node.
- Portainer Agent.

IP Tailscale:

`100.90.112.124`

IP LAN:

`192.168.1.100`

### Subnet Router

Anuncia la red:

`192.168.1.0/24`

Esto permite que clientes autorizados de Tailscale puedan alcanzar dispositivos de la LAN que no ejecutan Tailscale directamente.

### Exit Node

Anuncia:

- `0.0.0.0/0`
- `::/0`

Puede utilizarse como Exit Node para enviar tráfico de Internet de un cliente Tailscale a través de la conexión del hogar.

### IP forwarding

Configuración verificada:

```text
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
