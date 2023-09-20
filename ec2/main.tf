terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


resource "aws_security_group" "allow_ssh" {
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = "allow_ssh"
    "Description" = "Allow SSH"

  }
}

resource "aws_instance" "docker-engine" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = "prod_ssh_key"
  tags = {
    Name = "docker-engine"
  }

  provisioner "file" {
    source      = "C:\\Users\\josia\\Desktop\\docker-lessons\\setup.sh"
    destination = "/tmp/setup.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # or another user depending on your instance AMI
    private_key = file("C:\\Users\\josia\\Desktop\\docker-lessons\\prod_ssh_key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh",
    ]

  }

}

output "public_ip" {
  value = aws_instance.docker-engine.public_ip
}


