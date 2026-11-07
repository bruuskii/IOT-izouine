#!/bin/bash
# izouineSW: K3s in agent mode, joining the server izouineS.

# Same fix as on the server: let the VM reach the internet through NAT.
ip route del default via 192.168.56.1

echo "Installing K3s in agent mode..."
curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="izouine-iot-token" sh -s - agent \
  --node-ip 192.168.56.111 \
  --flannel-iface enp0s8

echo "K3s agent installed."
