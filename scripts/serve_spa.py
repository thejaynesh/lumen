"""Tiny static server with SPA fallback (serves index.html for unknown paths).
Used only for local verification of the built web app.
Usage: python serve_spa.py [port]   (run from a dir; serves ../build/web)
"""
import http.server
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "build", "web")


class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def end_headers(self):
        # never cache, so rebuilds are always picked up
        self.send_header("Cache-Control", "no-store, must-revalidate")
        super().end_headers()

    def do_GET(self):
        path = self.translate_path(self.path)
        if not os.path.exists(path) or os.path.isdir(path) and not os.path.exists(
            os.path.join(path, "index.html")
        ):
            # SPA fallback
            self.path = "/index.html"
        return super().do_GET()


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8090
    print(f"Serving {ROOT} on http://localhost:{port} (SPA fallback, no-cache)")
    http.server.test(HandlerClass=SPAHandler, port=port, bind="127.0.0.1")
