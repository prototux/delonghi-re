#!/usr/bin/env python3
"""Static server for the repository root that also saves what test pages POST
to /log (test results, power board call records).

    python3 emulator/test/logserver.py [log file] [port]
    # from the repository root; the log defaults to test.log, the port to 8765

Then open for instance
http://127.0.0.1:8765/ecam23.450_displayboard_reverse/emulator/test/pb_trace.html?post
and wait for the __END__ line in the log.
"""
import http.server
import os
import sys

LOG = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else 'test.log')
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 8765


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        n = int(self.headers.get('Content-Length', 0))
        data = self.rfile.read(n).decode('utf8', 'replace')
        if self.path == '/log':
            with open(LOG, 'a') as f:
                f.write(data + '\n')
        self.send_response(204)
        self.end_headers()

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()

    def log_message(self, *args):
        pass


if __name__ == '__main__':
    print(f'serving {os.getcwd()} on http://127.0.0.1:{PORT}/, POST /log -> {LOG}')
    http.server.ThreadingHTTPServer(('127.0.0.1', PORT), Handler).serve_forever()
