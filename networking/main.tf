#---------------networking/main.tf-------------------

data "aws_availability_zones" "available" {}
resource "random_integer" "random" {
  min = 1
  max = 100
}
resource "random_shuffle" "public_az" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}
resource "aws_vpc" "ecs-vpc"{
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "ECS VPC"
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_subnet" "public_subnet"{
    vpc_id = aws_vpc.ecs-vpc.id
    count = var.public_sn_count
    cidr_block = var.public_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone = random_shuffle.public_az.result[count.index]
    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    count = var.private_sn_count
    vpc_id = aws_vpc.ecs-vpc.id
    cidr_block = var.private_cidrs[count.index]
    map_public_ip_on_launch = false
    availability_zone = random_shuffle.public_az.result[count.index]
  
}

resource "aws_internet_gateway" "ecs-igw" {
    vpc_id = aws_vpc.ecs-vpc.id
    tags = {
        Name = "ecs-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.ecs-vpc.id
    tags = {
        Name = "Public Rote Table"
    }
}

resource "aws_route" "default_route" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs-igw.id
}

resource "aws_default_route_table" "default_rt" {
    default_route_table_id = aws_vpc.ecs-vpc.default_route_table_id
    tags = {
      "Name" = "private route table"
    }
}

resource "aws_route_table_association" "public_assoc" {
  count = var.public_sn_count
  subnet_id =   aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "lb" {
  name        = "ecs-alb-security-group"
  vpc_id      = aws_vpc.ecs-vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hello_world_task" {
  name        = "example-task-security-group"
  vpc_id      = aws_vpc.ecs-vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 5000
    to_port         = 5000
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
