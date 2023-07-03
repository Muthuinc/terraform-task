terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "ap-southeast-2"
  access_key = "***************"  #type your IAM access key - user should have full VPC and EC2 permission
  secret_key = "***************"  #type your IAM secret key
}

resource "aws_vpc" "Isla_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "abygaile"
  }
}

# Subnet creation -1

resource "aws_subnet" "Public_1" {
  vpc_id     = aws_vpc.Isla_vpc.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "pub1"
  }
}

# Subnet creation -2

resource "aws_subnet" "Public_2" {
  vpc_id     = aws_vpc.Isla_vpc.id
  cidr_block = "10.0.1.0/28"
  availability_zone = "ap-southeast-2b"
  tags = {
    Name = "pub2"
  }
}

# Subnet creation -3

resource "aws_subnet" "Public_3" {
  vpc_id     = aws_vpc.Isla_vpc.id
  cidr_block = "10.0.2.0/28"
  availability_zone = "ap-southeast-2c"
  tags = {
    Name = "pub3"
  }
}
 # Internet gateway

resource "aws_internet_gateway" "Pubgw" {
  vpc_id = aws_vpc.Isla_vpc.id

  tags = {
    Name = "Ig"
  }
}

#route table 

resource "aws_route_table" "Pubroute" {
  vpc_id = aws_vpc.Isla_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Pubgw.id
  }
}

# route table association with subnet

resource "aws_route_table_association" "sub" {
  subnet_id      = aws_subnet.Public_1.id
  route_table_id = aws_route_table.Pubroute.id
}

resource "aws_route_table_association" "subb" {
  subnet_id      = aws_subnet.Public_2.id
  route_table_id = aws_route_table.Pubroute.id
}

resource "aws_route_table_association" "subbb" {
  subnet_id      = aws_subnet.Public_3.id
  route_table_id = aws_route_table.Pubroute.id
}

#Security groups 

resource "aws_security_group" "group1" {
  name        = "allow_tls"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.Isla_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allowall"
  }
}
#Vpc creation is over .....

#Ec2 instance creation
#linux instance
resource "aws_instance" "instance1" {
  ami                     = "ami-06cd706b6bacee637"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.Public_1.id
  vpc_security_group_ids  = [ aws_security_group.group1.id ]
  key_name                = "terminal"
  associate_public_ip_address = true

}

# instance launched in ubuntu 

resource "aws_instance" "instance2" {
  ami                     = "ami-0310483fb2b488153"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.Public_2.id
  vpc_security_group_ids  = [ aws_security_group.group1.id ]
  key_name                = "terminal"
  associate_public_ip_address = true

}
