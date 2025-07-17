#!/usr/bin/env python3

import os
import sys
import http.server
import socketserver

PORT = 8080
USE_CGI = True   # Always use CGI
# Set this to "" to serve from the script's directory, or set to "work" or any subdir name.
SERVE_DIR = ""   

script_dir = os.path.dirname(os.path.abspath(__file__))
serve_path = os.path.join(script_dir, SERVE_DIR)

os.chdir(serve_path)

if USE_CGI:
    Handler = http.server.CGIHTTPRequestHandler
else:
    Handler = http.server.SimpleHTTPRequestHandler

print(f"Serving from: {serve_path}")
print(f"Open http://localhost:{PORT}/ in your browser.")

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server.")