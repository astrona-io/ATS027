#!/usr/bin/env bash
# Check: behaviour. The process list shows the image entry point plus the new arguments.
set -uo pipefail
processes="$(kubectl -n starfleet exec deploy/probe -c web -- ps 2>/dev/null || true)"
case "$processes" in
  *"httpd -f -h /www -p 9090"*) echo "PASS: httpd runs with the image entry point and -p 9090" ;;
  *) echo "FAIL: no process 'httpd -f -h /www -p 9090' found in the container"; exit 1 ;;
esac
