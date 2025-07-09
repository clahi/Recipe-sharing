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
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "subnetA" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "subnetA"
  }
}

resource "aws_subnet" "subnetB" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "subnetB"
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
  route_table_id = aws_route_table.main_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

# Associating the main route table to the vpc
resource "aws_main_route_table_association" "main_rt_association" {
  vpc_id = aws_vpc.main.id
  route_table_id = aws_route_table.main_route_table.id
}

# Associating the public subnets to the main route table
resource "aws_route_table_association" "rt_subnetA_association" {
  subnet_id = aws_subnet.subnetA.id
  route_table_id = aws_route_table.main_route_table.id
}

# Associating the public subnets to the main route table
resource "aws_route_table_association" "rt_subnetB_association" {
  subnet_id = aws_subnet.subnetB.id
  route_table_id = aws_route_table.main_route_table.id
}