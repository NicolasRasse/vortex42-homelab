# Inventario de hosts

## vortex42-server

| Campo | Registro histórico / declaración |
|---|---|
| Función | Docker principal, administración y origen de backups |
| Sistema | Debian GNU/Linux 13 (trixie), x86-64 |
| Equipo | BANGHO MOV, formato portátil |
| CPU | Intel Core i5-3210M a 2,50 GHz; 4 CPU lógicas |
| Memoria | Aproximadamente 7,6 GiB utilizables |
| Disco | SanDisk SDSSDA240G; aproximadamente 223,6 GiB |
| Particiones históricas | EFI, raíz ext4 y swap |
| Red histórica | Ethernet activa; Wi-Fi inactiva |
| Software registrado | Docker 29.7.2; Compose v5.5.0 |
| Fecha del inventario | 2026-09-05 |

Consultar [inventario sanitizado](../inventory/vortex42-server.md). No interpretar versiones históricas como versiones recomendadas o verificadas hoy. La ruta esperada por los backups es `~/vortex42-homelab`, bajo la cuenta operadora existente.

## pi5-nube

Raspberry Pi identificada históricamente como host de Immich y destino de backups. Los scripts usan `/srv/backups`. No se incluyen datos confirmados de modelo exacto, RAM, sistema operativo, discos, RAID, montajes o espacio disponible.

Pendiente registrar: versión de Immich y base de datos, Compose, rutas de biblioteca y cargas, capacidad del disco, punto de montaje de backups, propietarios y backup de los datos propios del host. Una carpeta existente en `/srv/backups` no demuestra que esté montado el disco esperado.

## pi3-red

Raspberry Pi dedicada a Pi-hole, Tailscale, Subnet Router, Exit Node y Portainer Agent según la documentación anterior. Modelo exacto, sistema, almacenamiento y configuración del agente pendientes. Homepage declara integración con Pi-hole versión 6.

Pendiente registrar: configuración DNS/DHCP efectiva, upstreams, exportación recuperable de Pi-hole, unidad de Tailscale, rutas aprobadas y control de acceso al agente.

## Mantener el inventario

`scripts/inventory.sh` genera un informe relativo al directorio de ejecución. Aunque filtra Machine ID y Boot ID, incluye direcciones de red, nombres de pares e identidad Tailscale. Generar el informe en una carpeta privada fuera del repositorio, revisarlo y trasladar únicamente el resumen sanitizado. No ejecutar y añadir su salida automáticamente a Git.

Registrar hardware, sistema, rol, discos/montajes, servicios y fecha. Mantener las direcciones concretas y detalles privados de administración en el inventario privado del operador.
