#!/bin/bash
# izouineS: K3s in server mode + three web applications behind an Ingress.

# Vagrant puts a default route on the private network (192.168.56.1) that
# hides the NAT one: remove it so the VM can reach the internet.
ip route del default via 192.168.56.1

echo "Installing K3s in server mode..."
curl -sfL https://get.k3s.io | sh -s - server \
  --node-ip 192.168.56.110 \
  --flannel-iface enp0s8 \
  --write-kubeconfig-mode 644 \
  --disable metrics-server

echo "Deploying the three applications and the Ingress..."
kubectl apply -f /tmp/confs

echo "Applications deployed."
