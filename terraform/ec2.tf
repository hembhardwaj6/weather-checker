resource "aws_instance" "public_ec2" {
  provider                    = aws.us-west
  ami                         = data.aws_ami.ubuntu.id  #  for_each      = toset(["instance1", "instance2", "instance3"])
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  security_groups             = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public.id
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
      private_key = aws_key_pair.key_pair.key_name
      host        = self.public_ip

    }
    inline = [
      "sudo mkdir -p /app",
      "sudo apt install python-pip",
      "cd /app",
      "pip install --no-cache-dir -r requirements.txt",
      "gunicorn -w 1 -b 0.0.0.0:5000 main:app"
    ]
  }
  # connection {
  #   type        = "ssh"
  #   user        = "ubuntu"
  #   private_key = aws_key_pair.key_pair.key_name
  #   host        = self.public_ip
  #
  # }

  depends_on                  = [aws_key_pair.key_pair, aws_internet_gateway.gw]
}


resource "aws_instance" "private_ec2" {
  provider                    = aws.us-west
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  security_groups             = [aws_security_group.private_sg.id]
  subnet_id                   = aws_subnet.private.id
  availability_zone           = var.availability_zone

  depends_on                  = [aws_key_pair.key_pair]
}
