#!/usr/bin/env python3
"""Serve the throwaway ClipEdit Phase 1 prototype locally."""

from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HOST = "127.0.0.1"
PORT = 4173
DIRECTORY = Path(__file__).resolve().parent


class PrototypeHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(DIRECTORY), **kwargs)


if __name__ == "__main__":
    print(f"ClipEdit Phase 1: http://{HOST}:{PORT}/")
    try:
        ThreadingHTTPServer((HOST, PORT), PrototypeHandler).serve_forever()
    except KeyboardInterrupt:
        print("\nPrototype server stopped.")
