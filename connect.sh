#!/usr/bin/env bash

# Aufgabe dieses Skripts:
# Vom Client aus mit dem VPN-Server verbinden

if [ "$#" -lt 3 ]; then
  echo "Fehler: Nicht alle Informationen angegeben."
  echo "Korrekter Aufruf: sudo bash connect.sh server-public-key client-vpn-ip client-vpn-private-keyfile"
  exit 1
fi

server_public_key="$1"
client_vpn_ip="$2"
client_vpn_private_keyfile="$3"

if [ -n "$4" ]; then
  public_server_ip="$4"
else
  public_server_ip="$(tofu state show aws_instance.app_server | grep -w public_ip | cut -d\" -f2)"
fi

set -ex

ip link del wg0 || true

ip link add wg0 type wireguard
ip link set wg0 up

# Eigene IP-Adresse innerhalb des VPN festlegen
ip addr add "$client_vpn_ip"/24 dev wg0
wg set wg0 private-key "$client_vpn_private_keyfile"

wg set wg0 peer "$server_public_key" allowed-ips 192.168.0.0/24 endpoint $public_server_ip:51820 persistent-keepalive 10
