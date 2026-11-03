#!/usr/bin/env python3
"""Minimal HTTP file server that tolerates hostnames >63 chars.

Python 3.13's http.server calls socket.getfqdn() during bind, which
passes through the IDNA codec.  IDNA labels are capped at 63 chars,
so VMs whose generated hostname exceeds that (common with SecGen's
<prefix>-<scenario>-<system> naming) crash with UnicodeEncodeError.

This wrapper catches that and falls back to 'localhost'.
"""
import http.server
import socketserver
import socket
import sys


class SafeHTTPServer(http.server.HTTPServer):
    def server_bind(self):
        socketserver.TCPServer.server_bind(self)
        host, port = self.server_address[:2]
        try:
            self.server_name = socket.getfqdn(host)
        except (UnicodeError, socket.herror, OSError):
            self.server_name = host or 'localhost'
        self.server_port = port


if __name__ == '__main__':
    bind = sys.argv[1] if len(sys.argv) > 1 else '0.0.0.0'
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8080
    handler = http.server.SimpleHTTPRequestHandler
    with SafeHTTPServer((bind, port), handler) as httpd:
        httpd.serve_forever()
