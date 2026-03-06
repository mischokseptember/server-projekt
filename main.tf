provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/*-24.04-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]  # Canonical
}

resource "aws_security_group" "allow_all" {
  name_prefix = "allow-all-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id

  # Mit der folgenden Zeile wird das Servermodell ausgewählt.
  # t2.micro kostet wenige Cent pro Stunde.
  # Andere Modelle kosten hunderte Euro pro Stunde.
  # Bitte auf t2.micro lassen.
  # Läuft auf Ingos private Kreditkarte.
  # !!!!!!!!!!!!
  instance_type               = "t2.micro"

  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = true

  tags = {
    Name = "vpn"
  }

  user_data = <<-EOF
    #!/usr/bin/env bash

    set -ex

    cat >> /home/ubuntu/.ssh/authorized_keys <<KEYS
    ${join("\n", [for f in fileset("${path.module}/ssh-keys", "*.pub") : file("${path.module}/ssh-keys/${f}")])}
    KEYS

    # Neueste Paketdatenbank holen
    apt update

    # Sicherheitshalber alle Programme auf den neuesten Stand bringen
    apt dist-upgrade -y

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

    # Wireguard einen Peer bekannt machen
    wg set wg0 peer ${trimspace(file("vpn-keys/ingo.pub"))} allowed-ips 192.168.0.101/32 persistent-keepalive 10
    wg set wg0 peer ${trimspace(file("vpn-keys/faruq.pub"))} allowed-ips 192.168.0.2/32 persistent-keepalive 10
    wg set wg0 peer ${trimspace(file("vpn-keys/benni.pub"))} allowed-ips 192.168.0.69/32 persistent-keepalive 10
    wg set wg0 peer ${trimspace(file("vpn-keys/andre.pub"))} allowed-ips 192.168.0.150/32 persistent-keepalive 10
    wg set wg0 peer ${trimspace(file("vpn-keys/tom.pub"))} allowed-ips 192.168.0.24/32 persistent-keepalive 10

    # Öffentliches Serverschloss an interessierte Handys schicken
    curl -s -d "IP: $(curl ifconfig.me), öffentliches Schloss: $vpnpub, Installationslaptop: ${env("HOSTNAME")}" https://ntfy.sh/mischok-citest
  EOF
}
