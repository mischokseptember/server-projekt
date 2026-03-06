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

resource "aws_key_pair" "key-vpn" {
  key_name   = "key-vpn"
  public_key = file("~/.ssh/id_ed25519.pub")
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

  key_name                    = aws_key_pair.key-ingo.key_name
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  associate_public_ip_address = true

  tags = {
    Name = "vpn"
  }

  user_data = <<-EOF
    #!/usr/bin/env bash
    echo Hallo
  EOF
}
