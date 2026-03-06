#!/usr/bin/env bash

# Aufgabe dieses Skripts:
# Vom Client aus mit dem VPN-Server verbinden

set -ex

ip link del wg0 || true

ip link add wg0 type wireguard
ip link set wg0 up

# Eigene IP-Adresse innerhalb des VPN festlegen
ip addr add 192.168.0.101/24 dev wg0
wg set wg0 private-key vpn-keys/ingo.priv

public_server_ip="$(tofu state show aws_instance.app_server | grep -w public_ip | cut -d\" -f2)"

wg set wg0 peer DcqwCWnAcsWZrdRPcGs2YTVUGbl5UzglIyVGD7og52Q= allowed-ips 192.168.0.0/24 endpoint $public_server_ip:51820 persistent-keepalive 10
