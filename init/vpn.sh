#!/usr/bin/env bash

set -ex

# Wireguard installieren
apt install -y wireguard

# Schlüsselpaar erzeugen
vpnpriv=$(wg genkey)
vpnpub=$(echo "$vpnpriv" | wg pubkey)

# Wireguard-Interface aktivieren
ip link add wg0 type wireguard
ip link set wg0 up

# Eigene IP-Adresse innerhalb des VPN festlegen
ip addr add 192.168.0.1/24 dev wg0

# Wireguard anweisen, auf Port 51820 auf eingehende VPN-Pakete zu lauschen
wg set wg0 listen-port 51820

# Wireguard den eigenen privaten Schlüssel bekannt machen
wg set wg0 private-key <(echo "$vpnpriv")

# Wireguard die Peers bekannt machen
wg set wg0 peer $(cat vpn-keys/ingo.pub) allowed-ips 192.168.0.101/32 persistent-keepalive 10
wg set wg0 peer $(cat vpn-keys/faruq.pub) allowed-ips 192.168.0.2/32 persistent-keepalive 10
wg set wg0 peer $(cat vpn-keys/benni.pub) allowed-ips 192.168.0.69/32 persistent-keepalive 10
wg set wg0 peer $(cat vpn-keys/andre.pub) allowed-ips 192.168.0.150/32 persistent-keepalive 10
wg set wg0 peer $(cat vpn-keys/tom.pub) allowed-ips 192.168.0.24/32 persistent-keepalive 10
wg set wg0 peer $(cat vpn-keys/denise.pub) allowed-ips 192.168.0.102/32 persistent-keepalive 10

# Öffentliches Serverschloss an interessierte Handys schicken
curl -s -d "IP: $(curl ifconfig.me), öffentliches Schloss: $vpnpub" https://ntfy.sh/mischok-citest
