terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "prodaccess"
  region  = "us-west-2"
}

resource "aws_key_pair" "appserver" {
  key_name   = "appserver.pem"
  public_key = file("appserver_pub.pem")
}


resource "aws_security_group" "appserver_security" {
  name        = "appserver_security-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["157.33.52.177/32"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["157.33.52.177/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["157.33.52.177/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  key_name      = aws_key_pair.appserver.key_name
  ami           = "ami-03d5c68bab01f3496"
  instance_type = "t2.micro"


  vpc_security_group_ids = [
    aws_security_group.appserver_security.id
  ]

  tags = {
    Name = "AppServer"
  }
}

