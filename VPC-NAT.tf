resource "aws_vpc" "MyVPC" {
  tags = {
    Name = "Terraform-VPC"
  }
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy = "default"
}

resource "aws_subnet" "MySubnet" {
  vpc_id            = aws_vpc.MyVPC.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "MySubnet2" {
  vpc_id            = aws_vpc.MyVPC.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet"
  }
}


resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC.id
  tags = {
    Name = "Terraform-IGW"
  }
}

resource "aws_nat_gateway" "myNAT" {
  allocation_id = aws_eip.myEIP.id
  subnet_id    = aws_subnet.MySubnet.id
    tags = {
        Name = "Terraform-NAT"
    }
    depends_on = [ aws_internet_gateway.MyIGW ]
}

resource "aws_eip" "myEIP" {
    domain = "vpc"
    tags = {
        Name = "Terraform-EIP"
    }
}

resource "aws_route_table" "MyRouteTable" {
  vpc_id = aws_vpc.MyVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }
  tags = {
    Name = "Public-RouteTable"
  }
}

resource "aws_route_table" "MyRouteTable-2" {
  vpc_id = aws_vpc.MyVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.myNAT.id
  }
  tags = {
    Name = "Private-RouteTable"
  }
}

resource "aws_route_table_association" "MyRouteTableAssociation" {
  subnet_id      = aws_subnet.MySubnet.id
  route_table_id = aws_route_table.MyRouteTable.id
}

resource "aws_route_table_association" "MyRouteTableAssociation-2" {
  subnet_id      = aws_subnet.MySubnet2.id
  route_table_id = aws_route_table.MyRouteTable-2.id
}

