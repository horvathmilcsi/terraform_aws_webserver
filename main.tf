/**
 * # Create an nginx webserver on centos in AWS
 *
 * This module creates an nginx webserver on centos in AWS.
 * Necessary steps:
 * #0 create security keys and ppk
 * #1 create vpc
 * #2 create internet gateway
 * #3 create route table
 * #4 create subnet
 * #5 associate subnet and route table
 * #6 create security group
 * #7 create netwoek interface ??
 * #8 create an elastic IP
 * #9 create Centos server and install nginx
 * The EC2 instance will be deafulted in region us-east-1 and from the most recent amazon-linux2 official image.
 * Default Instance name will be practice-nginx, default instance type will be t2.micro.
 * #10 DELETE SECURITY KEYS
 */

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

#1 create vpc

 resource "aws_vpc" "webserver_vpc_20240105" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "vpc for practice webserver 20240105"
  }
}

#2 create internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.webserver_vpc_20240105.id

  tags = {
    Name = "gateway for practice webserver 20240105"
  }
}

#3 create route table

resource "aws_route_table" "webserver_route_table_20240105" {
  vpc_id = aws_vpc.webserver_vpc_20240105.id

  route {
    cidr_block = "0.0.0.0/0" #"10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }

/*
  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id =  #aws_internet_gateway.gw.id
  }
*/
  tags = {
    Name = "Route table for practice webserver 20240105"
  }
}

#4 create subnet

resource "aws_subnet" "webserver_subnet_20240105" {
  vpc_id     = aws_vpc.webserver_vpc_20240105.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet for practice webserver 20240105"
  }
}

#5 associate subnet and route table

resource "aws_route_table_association" "webserver_association_20240105" {
  subnet_id      = aws_subnet.webserver_subnet_20240105.id
  route_table_id = aws_route_table.webserver_route_table_20240105.id
}

#6 create security group

resource "aws_security_group" "allow_web_traffic_20240105" {
  name        = "allow_web_traffic_20240105"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.webserver_vpc_20240105.id

  ingress {
    description      = "https from all Internet!"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # open to everyone! #[aws_vpc.main.cidr_block]
  }

  ingress {
    description      = "http from all Internet!"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # open to everyone! #[aws_vpc.main.cidr_block]
  }

  ingress {
    description      = "ssh from all Internet!"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # open to everyone! #[aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_internet_ssh_http_https"
  }
}

#7 create network interface

resource "aws_network_interface" "webserver_wetwork_interface_20240105" {
  subnet_id       = aws_subnet.webserver_subnet_20240105.id
  private_ips     = ["10.10.1.50"]
  security_groups = [aws_security_group.allow_web_traffic_20240105.id]

  tags = {
    Name = "webserver_wetwork_interface_20240105"
  }
/*
  attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }
*/
}

#8 create an elastic IP

resource "aws_eip" "webserver_eip_20240105" {
  domain = "vpc"
  network_interface = aws_network_interface.webserver_wetwork_interface_20240105.id
  associate_with_private_ip = "10.10.1.50"
  depends_on = [ aws_internet_gateway.gw ]
  tags = {
    Name = "webserver_eip_20240105"
  }
}

#9 create Centos server and install nginx
# The EC2 instance will be defaulted in region us-east-1 and from the most recent amazon-linux2 official image.
# Default Instance name will be practice-nginx, default instance type will be t2.micro.
resource "aws_instance" "webserver_instance_20240105" {
  ami = "ami-0aedf6b1cb669b4c7"
  availability_zone = "us-east-1a"
  instance_type = "t2.micro"
  key_name = "webserver_project_key_pair_20240105"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.webserver_wetwork_interface_20240105.id
  }
  tags = {
    name = "webserver_instance_20240105"
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install epel-release -y
  sudo yum install nginx -y
  curl -I 127.0.0.1
  sudo systemctl start nginx
  sudo systemctl enable nginx
  EOF

}

output "instance_id" {
 value = aws_instance.webserver_instance_20240105.id
}

output "public_ip" {
 value = aws_instance.webserver_instance_20240105.public_ip
}

#ssh -i "c:\Users\horva\Downloads\webserver_project_key_pair_20240105.pem" centos@54.237.68.18  
#[centos@ip-10-10-1-50 ~]$ pwd