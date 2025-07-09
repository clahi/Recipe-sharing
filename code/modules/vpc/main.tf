terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
  }
  required_version = ">= 1.7"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet gateway"
  }
}

resource "aws_internet_gateway_attachment" "ig_attachment" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.main.id
}

# Creating public subnets
resource "aws_subnet" "public_subnetA" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability-zone-1a

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnetA"
  }
}

resource "aws_subnet" "public_subnetB" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability-zone-1b

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnetB"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main Route Table"
  }
}

# a public route of the route table
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.main_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Associating the main route table to the vpc
resource "aws_main_route_table_association" "main_rt_association" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main_route_table.id
}

# Associating the public subnets to the main route table
resource "aws_route_table_association" "rt_subnetA_association" {
  subnet_id      = aws_subnet.public_subnetA.id
  route_table_id = aws_route_table.main_route_table.id
}

# Associating the public subnets to the main route table
resource "aws_route_table_association" "rt_subnetB_association" {
  subnet_id      = aws_subnet.public_subnetB.id
  route_table_id = aws_route_table.main_route_table.id
}

# Creating private subnets
resource "aws_subnet" "private_subnetA" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability-zone-1a


  tags = {
    Name = "private-subnetA"
  }
}

resource "aws_subnet" "private_subnetB" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability-zone-1b


  tags = {
    Name = "private-subnetB"
  }
}

# Creating a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

# A route to the nat gateway inside the public subnet
resource "aws_route" "nat_route" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.public_nat_gateway.id
}

# Associating the private subnets with the private route table
resource "aws_route_table_association" "private1a-association" {
  subnet_id = aws_subnet.private_subnetA.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private1b-association" {
  subnet_id = aws_subnet.private_subnetB.id
  route_table_id = aws_route_table.private_route_table.id
}

# Creating an elastic ip to be associated with a nat gate way
resource "aws_eip" "eip" {
  tags = {
    Name = "eip"
  }
}

# A nat gateway for the instances in the private subnet to access the internet
resource "aws_nat_gateway" "public_nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public_subnetA.id

  tags = {
    Name = "public-nat-gateway"
  }
}

# Creating an ec2 for testing purposes
resource "aws_key_pair" "key" {
  key_name   = "demo-key"
  public_key = file("${path.module}/key/demo-key.pub")
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "testing" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.security_group.id]

  subnet_id = aws_subnet.public_subnetA.id

  key_name = aws_key_pair.key.key_name
}

resource "aws_security_group" "security_group" {
  name        = "allow-ssh"
  description = "Allow ssh from the internet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ingress" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}