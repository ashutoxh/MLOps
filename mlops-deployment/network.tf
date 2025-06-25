resource "aws_vpc" "mlops_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "mlops-vpc"
  }
}

resource "aws_subnet" "mlops_subnets" {
  count             = length(var.subnet_cidrs)
  vpc_id            = aws_vpc.mlops_vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "mlops-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "mlops_igw" {
  vpc_id = aws_vpc.mlops_vpc.id
  tags = {
    Name = "mlops-igw"
  }
}

resource "aws_route_table" "mlops_rt" {
  vpc_id = aws_vpc.mlops_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mlops_igw.id
  }
  tags = {
    Name = "mlops-rt"
  }
}

resource "aws_route_table_association" "mlops_rta" {
  count          = length(aws_subnet.mlops_subnets)
  subnet_id      = aws_subnet.mlops_subnets[count.index].id
  route_table_id = aws_route_table.mlops_rt.id
}

resource "aws_security_group" "mlops_sg" {
  name        = "mlops-security-group"
  description = "Allow HTTP, container ports, and SSH traffic"
  vpc_id      = aws_vpc.mlops_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Public HTTP access
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Any ssh access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]   # Full outbound access
  }

  tags = {
    Name = "mlops-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "mlops-alb-sg"
  description = "Allow HTTP inbound to ALB"
  vpc_id      = aws_vpc.mlops_vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mlops-alb-sg" }
}

# Instance Security Group
resource "aws_security_group" "instance_sg" {
  name        = "mlops-instance-sg"
  description = "Allow traffic from ALB and SSH"
  vpc_id      = aws_vpc.mlops_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "YOLO from ALB"
    from_port       = 5001
    to_port         = 5001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "Depth from ALB"
    from_port       = 5050
    to_port         = 5050
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mlops-instance-sg" }
}

# resource "aws_security_group" "ecs_instance_sg" {
#   name        = "ecs-instance-sg"
#   description = "Security group for ECS EC2 instances"
#   vpc_id      = aws_vpc.mlops_vpc.id

#   ingress {
#     from_port       = 0
#     to_port         = 65535
#     protocol        = "tcp"
#     security_groups = [aws_security_group.mlops_sg.id]  # ALB only
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]   # Any ssh access
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]   # Full outbound access
#   }
# }
