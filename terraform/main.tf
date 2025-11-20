terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_support   = true   # usually enabled by default, but good to specify
  enable_dns_hostnames = true   # this enables DNS hostnames for instances launched in 
  tags = {
    Name = "k8s-vpc"
  }
}

# 3 Availability Zones (AZs)
data "aws_availability_zones" "available" {}

# 3 Subnetze in 3 verschiedenen AZs
resource "aws_subnet" "subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "k8s-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "k8s-igw"
  }
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "k8s-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "rta" {
  count          = 3
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.rt.id
}

# Security Group kubernetes
resource "aws_security_group" "kubernetes" {
  name        = "kubernetes"
  description = "Allow all inbound traffic for Kubernetes nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow all inbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.cidr_block,"81.6.51.120/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "kubernetes"
  }
}

# Key Pair aus lokalem Public Key
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.publickeyfile)
}

# Ubuntu 24.04 LTS AMI - Beispiel für us-east-1 (muss ggf. angepasst werden)
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}


# Master Nodes
resource "aws_instance" "master_nodes" {
  count                       = 1
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnets[count.index % length(aws_subnet.subnets)].id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name       = "master-node-${count.index + 1}"
    k8s        = "1"
    masternode = "1"
  }
}

# Join Master Nodes
resource "aws_instance" "join_master_nodes" {
  count                       = var.join_master_count
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnets[(count.index + 1 ) % length(aws_subnet.subnets)].id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name              = "join-master-node-${count.index + 1}"
    k8s               = "1"
    join_master_nodes = "1"
  }
}

# Join Worker Nodes
resource "aws_instance" "join_worker_nodes" {
  count                       = var.join_worker_count
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnets[count.index % length(aws_subnet.subnets)].id
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.kubernetes.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name              = "join-worker-node-${count.index + 1}"
    k8s               = "1"
    join_worker_nodes  = "1"
  }
}

