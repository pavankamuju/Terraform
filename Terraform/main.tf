resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "pub_sub" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet"
  }
}
resource "aws_subnet" "prt_sub" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "private_subnet"
  }
}  

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.myvpc.id  
}

resource "aws_route_table" "pubRT"{
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.pub_sub.id
  route_table_id = aws_route_table.pubRT.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.pub_sub.id
}

resource "aws_route_table" "prtRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT.id
  }
  tags = {
    Name = "PrivateRouteTable"
  }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.prt_sub.id
  route_table_id = aws_route_table.prtRT.id
}
resource "aws_security_group" "Jenkins_SG" {
    name = "Jenkins_SG"
    description = "Allow SSH and HTTP inbound traffic"
    vpc_id = aws_vpc.myvpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "Jenkins" {
  ami = var.ami_id
  instance_type = var.instance_value
  key_name = var.key_pair_value
  subnet_id = aws_subnet.pub_sub.id
  security_groups = [aws_security_group.Jenkins_SG.id]
  user_data = "${file("userdata.sh")}"

  tags = {
    Name = "Jenkins"
  } 
}

resource "aws_security_group" "Docker_SG" {
    name = "Docker_SG"
    description = "Allow SSH and HTTP inbound traffic"
    vpc_id = aws_vpc.myvpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    }


resource "aws_instance" "Docker" {
  ami = var.ami_id
  instance_type = var.instance_value
  key_name = var.key_pair_value
  subnet_id = aws_subnet.prt_sub.id
  security_groups = [aws_security_group.Docker_SG.id]
  user_data = "${file("userdata1.sh")}"

  tags = {
    Name = "Docker"
  } 
}
resource "aws_instance" "private-1" {
  ami = var.ami_id
  instance_type = var.instance_value
  key_name = var.key_pair_value
  subnet_id = aws_subnet.prt_sub.id
  security_groups = [aws_security_group.Docker_SG.id]

tags = {
  Name ="private-1"
}
}