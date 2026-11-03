#!/usr/bin/env bash
# Check: kind and behaviour. node-agent is a DaemonSet with one ready Pod on every node.
set -uo pipefail

if kubectl -n starfleet get deployment node-agent >/dev/null 2>&1; then
  echo "FAIL: a Deployment named node-agent still exists"
  exit 1
fi
if ! kubectl -n starfleet get daemonset node-agent >/dev/null 2>&1; then
  echo "FAIL: DaemonSet node-agent not found in starfleet"
  exit 1
fi

nodes="$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"
desired="$(kubectl -n starfleet get daemonset node-agent -o jsonpath='{.status.desiredNumberScheduled}')"
ready="$(kubectl -n starfleet get daemonset node-agent -o jsonpath='{.status.numberReady}')"
if [ "$desired" != "$nodes" ] || [ "$ready" != "$nodes" ]; then
  echo "FAIL: nodes=$nodes desired=$desired ready=${ready:-0}; the DaemonSet must have one ready Pod per node"
  exit 1
fi

echo "PASS: DaemonSet node-agent has $ready ready Pod(s) for $nodes node(s)"
