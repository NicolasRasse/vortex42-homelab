#!/usr/bin/env python3

import json
import subprocess
from datetime import datetime
from pathlib import Path


STATUS_FILE = Path("/var/lib/vortex42-status/status.json")

STATUS_SSH_KEY = Path.home() / ".ssh" / "vortex42_status"
BACKUP_SSH_KEY = Path.home() / ".ssh" / "vaultwarden_backup"

BACKUP_MAX_AGE_HOURS = 36


def run_command(command):
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        timeout=15,
        check=True,
    )

    return result.stdout.strip()


# ============================================================
# ACTUALIZACIONES APT
# ============================================================

def count_local_updates():
    output = run_command([
        "bash",
        "-c",
        "apt list --upgradable 2>/dev/null | tail -n +2 | wc -l",
    ])

    return int(output)


def count_remote_updates(ip):
    output = run_command([
        "ssh",
        "-i", str(STATUS_SSH_KEY),
        "-o", "BatchMode=yes",
        "-o", "ConnectTimeout=5",
        "-o", "StrictHostKeyChecking=yes",
        f"vortex42@{ip}",
        "apt list --upgradable 2>/dev/null | tail -n +2 | wc -l",
    ])

    return int(output)


# ============================================================
# BACKUPS
# ============================================================

def latest_local_backup(directory):
    command = (
        f"find '{directory}' -maxdepth 1 -type f "
        "-printf '%T@\\n' 2>/dev/null | "
        "sort -n | tail -1"
    )

    output = run_command(["bash", "-c", command])

    if not output:
        return None

    return float(output)


def latest_remote_backup(directory):
    remote_command = (
        f"find '{directory}' -maxdepth 1 -type f "
        "-printf '%T@\\n' 2>/dev/null | "
        "sort -n | tail -1"
    )

    output = run_command([
        "ssh",
        "-i", str(BACKUP_SSH_KEY),
        "-o", "BatchMode=yes",
        "-o", "ConnectTimeout=5",
        "-o", "StrictHostKeyChecking=yes",
        "vortex42@pi5-nube",
        remote_command,
    ])

    if not output:
        return None

    return float(output)


def backup_info(timestamp):
    if timestamp is None:
        return {
            "status": "missing",
            "last": None,
            "age_hours": None,
        }

    backup_time = datetime.fromtimestamp(timestamp).astimezone()
    now = datetime.now().astimezone()

    age_hours = (now - backup_time).total_seconds() / 3600

    if age_hours <= BACKUP_MAX_AGE_HOURS:
        health = "ok"
    else:
        health = "stale"

    return {
        "status": health,
        "last": backup_time.isoformat(timespec="seconds"),
        "age_hours": round(age_hours, 1),
    }


# ============================================================
# MANEJO DE ERRORES
# ============================================================

def safe_check(name, function):
    try:
        value = function()
        print(f"{name}: {value}")
        return value

    except Exception as error:
        print(f"ERROR {name}: {error}")
        return None


# ============================================================
# MAIN
# ============================================================

def main():

    # ------------------------
    # Actualizaciones
    # ------------------------

    server_updates = safe_check(
        "APT vortex42-server",
        count_local_updates,
    )

    pi5_updates = safe_check(
        "APT pi5-nube",
        lambda: count_remote_updates("192.168.1.88"),
    )

    pi3_updates = safe_check(
        "APT pi3-red",
        lambda: count_remote_updates("192.168.1.100"),
    )

    # ------------------------
    # Backups
    # ------------------------

    server_backup = safe_check(
        "Backup server",
        lambda: latest_remote_backup(
            "/srv/backups/vortex42-homelab"
        ),
    )

    vaultwarden_backup = safe_check(
        "Backup Vaultwarden",
        lambda: latest_remote_backup(
            "/srv/backups/vaultwarden"
        ),
    )

    pihole_backup = safe_check(
        "Backup Pi-hole",
        lambda: latest_remote_backup(
            "/srv/backups/pihole"
        ),
    )

    immich_backup = safe_check(
        "Backup Immich",
        lambda: latest_local_backup(
            "/srv/backups/immich/database"
        ),
    )

    # ------------------------
    # JSON final
    # ------------------------

    status = {
        "homelab": "Vortex42",
        "status": "operational",

        "updates": {
            "server": server_updates,
            "pi5": pi5_updates,
            "pi3": pi3_updates,
        },

        "backups": {
            "server": backup_info(server_backup),
            "immich": backup_info(immich_backup),
            "pihole": backup_info(pihole_backup),
            "vaultwarden": backup_info(vaultwarden_backup),
        },

        "updated_at": datetime.now()
        .astimezone()
        .isoformat(timespec="seconds"),
    }

    temporary_file = STATUS_FILE.with_suffix(".tmp")

    with temporary_file.open(
        "w",
        encoding="utf-8"
    ) as file:

        json.dump(
            status,
            file,
            ensure_ascii=False,
            indent=2,
        )

    temporary_file.replace(STATUS_FILE)

    print()
    print(f"Estado actualizado: {STATUS_FILE}")


if __name__ == "__main__":
    main()