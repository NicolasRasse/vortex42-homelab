# Inventario de vortex42-server

Generado: 2026-09-05 10:44:18

## Sistema
```text
 Static hostname: vortex42-server
       Icon name: computer-laptop
         Chassis: laptop 💻
Operating System: Debian GNU/Linux 13 (trixie)
          Kernel: Linux 6.12.101+deb13-amd64
    Architecture: x86-64
 Hardware Vendor: BANGHO
  Hardware Model: MOV
Firmware Version: 4.6.5
   Firmware Date: Sat 2012-11-17
    Firmware Age: 13y 9month 2w 4d
```

## CPU
```text
Architecture:                            x86_64
CPU(s):                                  4
Model name:                              Intel(R) Core(TM) i5-3210M CPU @ 2.50GHz
NUMA node0 CPU(s):                       0-3
```

## Memoria
```text
               total       usado       libre  compartido   búf/caché  disponible
Mem:           7,6Gi       1,1Gi       4,5Gi        86Mi       2,4Gi       6,6Gi
Inter:         7,9Gi          0B       7,9Gi
```

## Discos
```text
NAME     SIZE TYPE FSTYPE MOUNTPOINTS MODEL
sda    223,6G disk                    SanDisk SDSSDA240G
├─sda1   976M part vfat   /boot/efi   
├─sda2 214,7G part ext4   /           
└─sda3   7,9G part swap   [SWAP]      
```

## Red
```text
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp0s25          UP             192.168.1.117/24 fe80::290:f5ff:fed7:f297/64 
wlp2s0           DOWN           
docker0          DOWN           172.17.0.1/16 fe80::28b8:d8ff:fe6f:6aaa/64 
tailscale0       UNKNOWN        100.92.205.107/32 fd7a:115c:a1e0::ef37:cd6c/128 fe80::a176:44cd:a81:a9fc/64 
```

## Tailscale
```text
100.92.205.107  vortex42-server    servidorvortex42@  linux    -                                                   
100.90.112.124  pi3-red            servidorvortex42@  linux    idle; offers exit node                              
100.68.83.125   pi5-nube           servidorvortex42@  linux    -                                                   
100.87.128.50   redmi-note-11      servidorvortex42@  android  offline, last seen 4d ago                           
100.88.199.27   servidor-vortex42  servidorvortex42@  linux    idle; offers exit node; offline, last seen 20d ago  

# Health check:
#     - Some peers are advertising routes but --accept-routes is false

IP Tailscale:
100.92.205.107
```

## Docker
```text
Docker: 29.7.2
Docker Compose: Docker Compose version v5.5.0
```
