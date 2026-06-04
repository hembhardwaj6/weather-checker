# This is where you put your resource declaration
locals {
  ingress-rules = {
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

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
}

# Create AWS key pair for EC2
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}

resource "aws_security_group" "sg" {
  name = var.sg_name
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
  }
  dynamic "ingress" {
    for_each = local.ingress-rules
    content {
      cidr_blocks = ingress.value["cidr_blocks"]
      protocol    = ingress.value["protocol"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
    }
  }
}

resource "aws_eip" "eip"{
  instance = aws_instance.ec2.id
  domain   = "vpc"
}

resource "aws_eip_association" "eip_ass"{
  instance_id = aws_instance.ec2.id
  allocation_id = aws_eip.eip.id

  depends_on = [aws_instance.ec2]
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu.id  #  for_each      = toset(["instance1", "instance2", "instance3"])
  instance_type               = var.instance_type
  # associate_public_ip_address = true    # using elastic ip so no need for this
  key_name                    = var.key_pair_name
  security_groups             = [aws_security_group.sg.id]
  depends_on                  = [aws_key_pair.key_pair]
  subnet_id                   = aws_subnet.private.id
  availability_zone           = var.availability_zone

  # copy all templates and python files to ec2 instance
  provisioner "file" {
    source      = "../templates"
    destination = "/app/templates"
  }
  provisioner "file" {
    source      = "main.py"
    destination = "/app/"
  }
  provisioner "file" {
    source      = "requirements.txt"
    destination = "/app/"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = aws_key_pair.key_pair
      host        = aws_eip.eip.public_ip

    }
    inline = [
      "sudo mkdir -p /app",
      "sudo apt install python-pip",
      "cd /app",
      "pip install --no-cache-dir -r requirements.txt",
      "gunicorn -w 1 -b 0.0.0.0:5000 main:app"
    ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = aws_key_pair.key_pair
    host        = aws_eip.eip.public_ip

  }
}
