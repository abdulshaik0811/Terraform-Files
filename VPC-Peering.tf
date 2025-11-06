#provider

provider "aws" {
  region = "us-east-1"
}

#VPC

resource "aws_vpc" "MyVPC" {
  tags = {
    Name = "Terraform-VPC"
  }
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy = "default"
}

resource "aws_vpc" "NewVPC" {
  tags = {
    Name = "New-VPC"
  }
  cidr_block = "11.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy = "default"
}

resource "aws_subnet" "MySubnet" {
  vpc_id            = aws_vpc.MyVPC.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "MY-Subnet"
  }
}

resource "aws_subnet" "MySubnet2" {
  vpc_id            = aws_vpc.NewVPC.id
  cidr_block        = "11.0.0.0/25"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "New-Subnet"
  }
}


resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC.id
  tags = {
    Name = "MY-IGW"
  }
}

resource "aws_internet_gateway" "MyIGW-2" {
  vpc_id = aws_vpc.NewVPC.id
  tags = {
    Name = "New-IGW"
  }
}

resource "aws_vpc_peering_connection" "Mypeering" {
  vpc_id = aws_vpc.MyVPC.id
  peer_vpc_id = aws_vpc.NewVPC.id
  auto_accept = true
  tags = {
    Name = "MY-new-Peering"
  }
}

resource "aws_route_table" "MyRouteTable" {
  vpc_id = aws_vpc.MyVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }
  route {
    cidr_block = "11.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.Mypeering.id
  }
  tags = {
    Name = "MY-RouteTable"
  }
}

resource "aws_route_table" "MyRouteTable-2" {
  vpc_id = aws_vpc.NewVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW-2.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.Mypeering.id
  }
  tags = {
    Name = "New-RouteTable"
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

#Security Groups

resource "aws_security_group" "allow_peering" {
  name   = "allow-peering-traffic"
  vpc_id = aws_vpc.MyVPC.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyVPC-Allow-Peering"
  }
}

resource "aws_security_group" "allow_peering_2" {
  name   = "allow-peering-traffic-2"
  vpc_id = aws_vpc.NewVPC.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NewVPC-Allow-Peering"
  }
}

#instances

resource "aws_instance" "Myinstance" {
  ami = "ami-0157af9aea2eef346"
  instance_type = "t3.micro"
  key_name = "Gkp"
  subnet_id = aws_subnet.MySubnet.id
  vpc_security_group_ids = [aws_security_group.allow_peering.id]
  tags = {
    Name = "MY-Instance"
  }
}

resource "aws_instance" "Myinstance2" {
  ami = "ami-0157af9aea2eef346"
  instance_type = "t3.micro"
  key_name = "Gkp"
  subnet_id = aws_subnet.MySubnet2.id
    vpc_security_group_ids = [aws_security_group.allow_peering_2.id]
  tags = {
    Name = "New-Instance"
  }
  
}

