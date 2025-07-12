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


# Creating public subnets
resource "aws_subnet" "public_subnetA" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability-zone-1a

  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "public_subnetB" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability-zone-1b

  map_public_ip_on_launch = true

  tags = {
    Name = "public"
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
    Name = "private"
  }
}

resource "aws_subnet" "private_subnetB" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability-zone-1b


  tags = {
    Name = "private"
  }
}

# Creating a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

# # A route to the nat gateway inside the public subnet
# resource "aws_route" "nat_route" {
#   route_table_id = aws_route_table.private_route_table.id
#   destination_cidr_block = "0.0.0.0/0"
#   # gateway_id = aws_nat_gateway.public_nat_gateway.id
# }

# Associating the private subnets with the private route table
resource "aws_route_table_association" "private1a-association" {
  subnet_id = aws_subnet.private_subnetA.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private1b-association" {
  subnet_id = aws_subnet.private_subnetB.id
  route_table_id = aws_route_table.private_route_table.id
}

# # Creating an elastic ip to be associated with a nat gate way
# resource "aws_eip" "eip" {
#   tags = {
#     Name = "eip"
#   }
# }

# # A nat gateway for the instances in the private subnet to access the internet
# resource "aws_nat_gateway" "public_nat_gateway" {
#   allocation_id = aws_eip.eip.id
#   subnet_id = aws_subnet.public_subnetA.id

#   tags = {
#     Name = "public-nat-gateway"
#   }
# }
