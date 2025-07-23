#!/usr/bin/env python3

import os
import sys
import http.server
import socketserver

PORT = 8080
USE_CGI = True
SERVE_DIR = ""

script_dir = os.path.dirname(os.path.abspath(__file__))
serve_path = os.path.join(script_dir, SERVE_DIR)

os.chdir(serve_path)

if USE_CGI:
    Handler = http.server.CGIHTTPRequestHandler
else:
    Handler = http.server.SimpleHTTPRequestHandler

class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

print(f"Serving from: {serve_path}")
print(f"Open http://localhost:{PORT}/ in your browser.")

with ReusableTCPServer(("", PORT), Handler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server.")
    finally:
        httpd.server_close()
        print("Server closed.")
        sys.exit(0)