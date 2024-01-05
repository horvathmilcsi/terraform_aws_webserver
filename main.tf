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

  tags = {
    Name = "Subnet for practice webserver 20240105"
  }
}

#5 associate subnet and route table
#6 create security group
#7 create netwoek interface ??
#8 create an elastic IP
#9 create Centos server and install nginx
# The EC2 instance will be deafulted in region us-east-1 and from the most recent amazon-linux2 official image.
# Default Instance name will be practice-nginx, default instance type will be t2.micro.
