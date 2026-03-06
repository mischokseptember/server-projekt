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
    echo "${file("ssh-keys/andre.pub")}" >> /home/ubuntu/.ssh/authorized_keys
    echo "${file("ssh-keys/benni.pub")}" >> /home/ubuntu/.ssh/authorized_keys
    echo "${file("ssh-keys/faruq.pub")}" >> /home/ubuntu/.ssh/authorized_keys
    echo "${file("ssh-keys/ingo.pub")}" >> /home/ubuntu/.ssh/authorized_keys
    echo "${file("ssh-keys/savo.pub")}" >> /home/ubuntu/.ssh/authorized_keys
    echo "${file("ssh-keys/tom.pub")}" >> /home/ubuntu/.ssh/authorized_keys
    echo Hallo
  EOF
}
