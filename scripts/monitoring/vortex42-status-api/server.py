#!/usr/bin/env python3

import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


HOST = "0.0.0.0"
PORT = 8091

STATUS_FILE = Path("/var/lib/vortex42-status/status.json")


class StatusHandler(BaseHTTPRequestHandler):

    def _send_json(self, data, status=200):
        body = json.dumps(
            data,
            ensure_ascii=False,
            indent=2
        ).encode("utf-8")

        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()

        self.wfile.write(body)

    def do_GET(self):

        if self.path == "/":
            self._send_json({
                "service": "Vortex42 Status API",
                "status": "online"
            })
            return

        if self.path == "/status":

            if not STATUS_FILE.exists():
                self._send_json({
                    "error": "status.json todavía no existe"
                }, 503)
                return

            try:
                with STATUS_FILE.open(
                    "r",
                    encoding="utf-8"
                ) as file:
                    data = json.load(file)

                self._send_json(data)

            except Exception as error:
                self._send_json({
                    "error": str(error)
                }, 500)

            return

        self._send_json({
            "error": "Not found"
        }, 404)

    def log_message(self, format, *args):
        return


def main():
    server = ThreadingHTTPServer(
        (HOST, PORT),
        StatusHandler
    )

    print(
        f"Vortex42 Status API escuchando en "
        f"http://{HOST}:{PORT}"
    )

    server.serve_forever()


if __name__ == "__main__":
    main()
