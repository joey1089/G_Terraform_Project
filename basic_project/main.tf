# ----- foundational project - to learn and understand basics - so everything is hardcoded
# ----- points to remember -> default VPC does not allow - cidr block
# Terraform required provider block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24"
    }
  }
  required_version = ">= 0.2.1"
}

provider "aws" {
  region = "us-east-1"
}

#Create Custom VPC
resource "aws_vpc" "myvpc_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc_vpc"
  }
}

resource "aws_subnet" "subnet_east1a" {
  vpc_id                  = aws_vpc.myvpc_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-us-east-1a"
  }
}
resource "aws_subnet" "subnet_east1b" {
  vpc_id                  = aws_vpc.myvpc_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-us-east-1b"
  }
}
resource "aws_subnet" "subnet_east1c" {
  vpc_id                  = aws_vpc.myvpc_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-us-east-1c"
  }
}

#Create internet gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc_vpc.id
  tags = {
    Name = "igw"
  }
}

#Create a Route Table and add router with igw and allow all
resource "aws_route_table" "igw_public_rt" {
  vpc_id = aws_vpc.myvpc_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Route Table"
  }
}

#Create Route Table explicit assoication  with the public subnet
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.subnet_east1a.id
  route_table_id = aws_route_table.igw_public_rt.id
}
resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.subnet_east1b.id
  route_table_id = aws_route_table.igw_public_rt.id
}
resource "aws_route_table_association" "public_rt3" {
  subnet_id      = aws_subnet.subnet_east1c.id
  route_table_id = aws_route_table.igw_public_rt.id
}

#Create securtiy group to allow http and ssh access
resource "aws_security_group" "web_sg" {
  Name        = "http_ssh_sg"
  description = "http and ssh allowed into ec2 instances"
  vpc_id      = aws_vpc.myvpc_vpc.id
  #Allow SSH access.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
    #ip removed
  }

  #Allow incoming HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ip removed
  }
  #Allow outgoing--access to web.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ec2_instance01 in AZ east-1a
resource "aws_instance" "Instance_01" {
  ami             = "ami-0b5eea76982371e91"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet_east1a.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    "Name" = "web-instance-1"
  }
  user_data = <<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl start httpd
    systemctl enable httpd

    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    echo '<head><title>Terraform Deployment Test</title></head>'  >> /var/www/html/index.html
    echo '<body style="background-color:rgb(109, 185, 109);">' >> /var/www/html/index.html
    echo '<h1 style="color:rgb(100, 27, 27);">Terraform deployed web server.</h1>' >> /var/www/html/index.html
    EOF
}
#Create ec2 instance02 in AZ east-1b
resource "aws_instance" "Instance_02" {
  ami             = "ami-0b5eea76982371e91"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet_east1b.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    "Name" = "web-instance-2"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl start httpd
    systemctl enable httpd

    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    echo '<head><title>Terraform Deployment Test</title></head>'  >> /var/www/html/index.html
    echo '<body style="background-color:rgb(109, 185, 109);">' >> /var/www/html/index.html
    echo '<h1 style="color:rgb(100, 27, 27);">Terraform deployed web server.</h1>' >> /var/www/html/index.html
    EOF
}

#Create ec2 instance03 in AZ east-1c
resource "aws_instance" "Instance_03" {
  ami             = "ami-0b5eea76982371e91"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet_east1c.id
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    "Name" = "web-instance-3ter "
  }
  user_data = <<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl start httpd
    systemctl enable httpd

    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    echo '<head><title>Terraform Deployment Test</title></head>'  >> /var/www/html/index.html
    echo '<body style="background-color:rgb(109, 185, 109);">' >> /var/www/html/index.html
    echo '<h1 style="color:rgb(100, 27, 27);">Terraform deployed web server.</h1>' >> /var/www/html/index.html
    EOF
}