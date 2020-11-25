terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "./.aws/credentials"
}

# Create a VPC
resource "aws_vpc" "personal_vpc" {
  cidr_block = "10.0.0.0/8"
}

# Create Internet Gateway
resource "aws_internet_gateway" "personal_igw" {
  vpc_id = aws_vpc.personal_vpc.id
}

# Create Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.personal_vpc.id
  cidr_block              = "10.2.0.0/16"
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "baston_sub" {
  vpc_id                  = aws_vpc.personal_vpc.id
  cidr_block              = "10.4.0.0/16"
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.personal_vpc.id
  cidr_block = "10.16.0.0/16"
}

# Create AWS Instance
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
}

resource "aws_instance" "mas_a" {
  ami           = data.aws_ami.centos.id
  instance_type = "t2.micro"

  private_ip = "10.2.0.1"
  subnet_id  = aws_subnet.public_sub.id
}

resource "aws_instance" "mas_b" {
  ami           = data.aws_ami.centos.id
  instance_type = "t2.micro"

  private_ip = "10.2.0.2"
  subnet_id  = aws_subnet.public_sub.id
}

resource "aws_instance" "bast_a" {
  ami           = data.aws_ami.centos.id
  instance_type = "t2.micro"

  private_ip = "10.4.0.1"
  subnet_id  = aws_subnet.baston_sub.id
}

resource "aws_instance" "sla_a" {
  ami           = data.aws_ami.centos.id
  instance_type = "t2.mirco"

  private_ip = "10.16.0.1"
  subnet_id  = aws_subnet.baston_sub.id
}

resource "aws_instance" "sla_b" {
  ami           = data.aws_ami.centos.id
  instance_type = "t2.mirco"

  private_ip = "10.16.0.2"
  subnet_id  = aws_subnet.private_subnet.id
}

resource "aws_instance" "sla_c" {
  ami           = data.aws_ami.centos.id
  instance_type = "t2.mirco"

  private_ip = "10.16.0.3"
  subnet_id  = aws_subnet.private_subnet.id
}

# Add Elastic IP to public servers
resource "aws_eip" "baston_ip" {
  vpc = true

  instance                  = aws_instance.bast_a.id
  associate_with_private_ip = "10.4.0.1"

  depends_on = [aws_internet_gateway.gw]
}
