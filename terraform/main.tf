# This is where you put your resource declaration
locals {
  public-ingress-rules = {
    "ssh" = {
      cidr_blocks = ["0.0.0.0/0"]
      protocol  = "-1"
      from_port = "0"
      to_port   = "0"
    }
    "https" = {
      cidr_blocks = ["0.0.0.0/0"]
      protocol  = "tcp"
      from_port = "5000"
      to_port   = "5000"
    }
  }
  private-ingress-rule = {
    "ssh" = {
      cidr_blocks = [aws_subnet.public.cidr_block]
      protocol = "-1"
      from_port = "0"
      to_port = "0"
    }
  }

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create AWS key pair for EC2
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}

resource "aws_security_group" "public_sg" {
  name = var.sg_name
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
  }
  dynamic "ingress" {
    for_each = local.public-ingress-rules
    content {
      cidr_blocks = ingress.value["cidr_blocks"]
      protocol    = ingress.value["protocol"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
    }
  }
}

resource "aws_eip" "eip"{
  instance = aws_instance.public_ec2.id
  domain   = "vpc"
}

resource "aws_eip_association" "eip_ass"{
  instance_id = aws_instance.public_ec2.id
  allocation_id = aws_eip.eip.id
}

resource "aws_security_group" "private_sg" {
  name = var.sg_name
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
  }
  dynamic "ingress" {
    for_each = local.private-ingress-rule
    content {
      cidr_blocks = ingress.value["cidr_blocks"]
      protocol    = ingress.value["protocol"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
    }
  }
}