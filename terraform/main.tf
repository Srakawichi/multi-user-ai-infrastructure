provider "aws" {
  region = var.region
}

# ---------------------------
# Amazon Linux 2023 AMI
# ---------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ---------------------------
# Default VPC + Subnet
# ---------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ---------------------------
# Security Group
# No inbound rules
# ---------------------------

resource "aws_security_group" "ollama_sg" {
  name        = "ollama-no-inbound"
  description = "No inbound access (SSM only)"
  vpc_id      = data.aws_vpc.default.id

  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ollama-no-inbound"
  }
}

# ---------------------------
# IAM Role for SSM
# ---------------------------

resource "aws_iam_role" "ssm_role" {

  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS Managed SSM Policy

resource "aws_iam_role_policy_attachment" "ssm_policy" {

  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

# Instance Profile

resource "aws_iam_instance_profile" "ssm_profile" {

  name = "ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name

}

# ---------------------------
# EC2 Instance
# ---------------------------

resource "aws_instance" "ollama_server" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ollama_SecurityGroup.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash

dnf update -y

dnf install -y docker git

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user
usermod -aG docker ssm-user

curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 \
-o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

EOF

  tags = {
    Name = "ollama-ssm-server"
  }
}