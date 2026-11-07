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

echo "Waiting for the applications and Traefik (their images come from the internet)..."
kubectl wait --for=condition=Available deployment --all --timeout=300s
until curl -s -H "Host: app1.com" http://192.168.56.110 | grep -q app1; do sleep 5; done

# Everything is downloaded: make enp0s8 (192.168.56.110) the primary interface
# again, i.e. the only default route, also after a reboot.
nmcli connection modify "$(nmcli -g GENERAL.CONNECTION device show enp0s3)" ipv4.never-default yes
ip route del default via 10.0.2.2
ip route replace default via 192.168.56.1 dev enp0s8 metric 100

echo "Applications deployed."
