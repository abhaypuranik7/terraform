# create a vpc

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

# create a public subnet

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "PublicSubnet"
  }
}

# create a private subnet

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "PrivateSubnet"
  }
}


# create an internet gateway

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "InternetGateway"
  }
}


# create a route table

resource "aws_route_table" "rt"{
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
tags = {
    Name = "myroute"
  }
}


# route table association

resource "aws_route_table_association" "RT_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
  
}


# create a security group for public instances

resource "aws_security_group" "public_sec_group" {
  name        = "pubsecgroup"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create a security group for private instance

resource "aws_security_group" "private_sec_group" {
  name        = "privatesecgroup"
  vpc_id      = aws_vpc.my_vpc.id
}

# create 2 network interfaces

resource "aws_network_interface" "public_NI" {
  subnet_id          = aws_subnet.public_subnet.id
  tags = {
    Name = "publicNI"
  }
}

resource "aws_network_interface" "private_NI" {
  subnet_id          = aws_subnet.private_subnet.id
  tags = {
    Name = "privateNI"
  }

}

# attach public and private security groups to respective network interfaces

resource "aws_network_interface_sg_attachment" "pub_sg_attachment" {
  security_group_id    = aws_security_group.public_sec_group.id
  network_interface_id = aws_network_interface.public_NI.id
}

resource "aws_network_interface_sg_attachment" "pvt_sg__attachment" {
  security_group_id    = aws_security_group.private_sec_group.id
  network_interface_id = aws_network_interface.private_NI.id
}

# create instances in public and private subnet

resource "aws_instance" "public_instance" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

   tags = {
    Name = "pub_instance"
  }
}

resource "aws_instance" "private_instance" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  
  tags = {
    Name = "private_instance"
  }
}
