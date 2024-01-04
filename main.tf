/**
 * # Create an nginx webserver on centos in AWS
 *
 * This module creates an nginx webserver on centos in AWS.
 * Necessary steps:
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
 */

 resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
}