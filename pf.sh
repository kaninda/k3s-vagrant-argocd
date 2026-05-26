#!/bin/bash
echo "==> Port-forward Prometheus sur http://localhost:9090 (auto-restart)..."
while true; do
  vagrant ssh k3s-cp -c "kubectl --namespace monitoring port-forward --address 0.0.0.0 svc/kube-prometheus-stack-prometheus 9090:9090"
  echo "    Port-forward coupé, restart dans 3s..."
  sleep 3
done