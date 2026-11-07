# Replace with your own application. This placeholder serves /health on 8080.
FROM python:3.12-slim
WORKDIR /app
RUN printf 'import http.server\nclass H(http.server.BaseHTTPRequestHandler):\n    def do_GET(self):\n        self.send_response(200)\n        self.end_headers()\n        self.wfile.write(b"ok")\nhttp.server.HTTPServer(("", 8080), H).serve_forever()\n' > server.py
EXPOSE 8080
CMD ["python", "server.py"]
