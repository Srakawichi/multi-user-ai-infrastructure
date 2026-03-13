provider "aws" {
  region = "eu-central-1"
}

# Amazon Linux 2023 AMI automatisch finden
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Default Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group ohne Inbound Regeln
resource "aws_security_group" "ollama_SecurityGroup" {
  name_prefix = "ollama-"
  description = "No inbound access"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "ollama_server" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "m7i-flex.large"

  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"

  vpc_security_group_ids = [
    aws_security_group.ollama_SecurityGroup.id
  ]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker git

              systemctl start docker
              systemctl enable docker

              usermod -aG docker ssm-user

              curl -L https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 \
              -o /usr/local/bin/docker-compose

              chmod +x /usr/local/bin/docker-compose
              EOF

  tags = {
    Name = "terraform"
  }
}
