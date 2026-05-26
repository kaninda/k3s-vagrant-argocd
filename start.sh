#!/bin/bash
set -e

echo "==> Setting up kubectl alias..."
vagrant ssh k3s-cp -c "echo 'alias k=kubectl' >> /home/vagrant/.bashrc"

echo "==> Installing kube-prometheus-stack..."
vagrant ssh k3s-cp -c "
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
  helm repo update && \
  helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --wait
"

echo "==> Waiting for all pods to be ready..."
vagrant ssh k3s-cp -c "kubectl -n monitoring wait --for=condition=Ready pods --all --timeout=300s"

echo "==> Starting port-forward on http://localhost:9090 ..."
echo "    (Ctrl+C pour arrêter)"
vagrant ssh k3s-cp -c "kubectl --namespace monitoring port-forward --address 0.0.0.0 svc/kube-prometheus-stack-prometheus 9090:9090"