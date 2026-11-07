#!/bin/bash
# izouineS: K3s in server (controller) mode.

# Vagrant puts a default route on the private network (192.168.56.1) that
# hides the NAT one: remove it so the VM can reach the internet.
ip route del default via 192.168.56.1

echo "Installing K3s in server (controller) mode..."
curl -sfL https://get.k3s.io | K3S_TOKEN="izouine-iot-token" sh -s - server \
  --node-ip 192.168.56.110 \
  --flannel-iface enp0s8 \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --disable metrics-server

echo "K3s server installed."
