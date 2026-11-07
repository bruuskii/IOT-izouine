#!/bin/bash
# izouineSW: K3s in agent mode, joining the server izouineS.

# Same fix as on the server: let the VM reach the internet through NAT.
ip route del default via 192.168.56.1

echo "Installing K3s in agent mode..."
curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="izouine-iot-token" sh -s - agent \
  --node-ip 192.168.56.111 \
  --flannel-iface enp0s8

# K3s is installed: make enp0s8 (192.168.56.111) the primary interface again,
# i.e. the only default route, also after a reboot.
nmcli connection modify "$(nmcli -g GENERAL.CONNECTION device show enp0s3)" ipv4.never-default yes
ip route del default via 10.0.2.2
ip route replace default via 192.168.56.1 dev enp0s8 metric 100

echo "K3s agent installed."
