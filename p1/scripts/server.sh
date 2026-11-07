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

echo "Waiting for the system pods (their images come from the internet)..."
until kubectl -n kube-system wait --for=condition=Available deployment/coredns --timeout=300s 2>/dev/null; do sleep 5; done

# K3s is installed: make enp0s8 (192.168.56.110) the primary interface again,
# i.e. the only default route, also after a reboot.
nmcli connection modify "$(nmcli -g GENERAL.CONNECTION device show enp0s3)" ipv4.never-default yes
ip route del default via 10.0.2.2
ip route replace default via 192.168.56.1 dev enp0s8 metric 100

echo "K3s server installed."
