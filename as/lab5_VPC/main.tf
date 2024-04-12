resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "example_1" {
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = var.subnet_cidr_1
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "example_2" {
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = var.subnet_cidr_2
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "tf_sg" {
  name        = "tf_sg"
  description = "tf_sg security group"
  vpc_id      = aws_vpc.tf_vpc.id

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

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "tf_ig" {
  vpc_id = aws_vpc.tf_vpc.id
}

resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.tf_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_ig.id
}

resource "aws_key_pair" "TF_key" {
    key_name = "TF_key"
    public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "local_file" "TF_key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "tf_key"
    file_permission = 400
}

# not repeating resources:
#locals {
#  subnets = {
#    "example_1" = aws_subnet.example_1.id,
#    "example_2" = aws_subnet.example_2.id
#  }
#}

#resource "aws_route_table_association" "example" {
#  for_each       = local.subnets
#  subnet_id      = each.value
# route_table_id = aws_route_table.tf_rt.id
#}

# repeating the resource:
resource "aws_route_table_association" "example_1" {
  subnet_id        = aws_subnet.example_1.id
  route_table_id   = aws_route_table.tf_rt.id
}

resource "aws_route_table_association" "example_2" {
  subnet_id        = aws_subnet.example_2.id
  route_table_id   = aws_route_table.tf_rt.id
}

resource "aws_instance" "vpc_demo" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tf_sg.id]
  subnet_id              = aws_subnet.example_1.id
  key_name               = "TF_key"

  depends_on = [aws_key_pair.TF_key]
}

variable "vpc_cidr" {
  default = "10.10.0.0/20"
}

variable "subnet_cidr_1" {
  default = "10.10.0.0/24"
}

variable "subnet_cidr_2" {
  default = "10.10.1.0/24"
}

output "vpc_id" {
  value = aws_vpc.tf_vpc.id
}

output "subnet_id_1" {
  value = aws_subnet.example_1.id
}

output "subnet_id_2" {
  value = aws_subnet.example_2.id
}

output "security_group_id" {
  value = aws_security_group.tf_sg.id
}

output "ec2_public_ip" {
  value = aws_instance.vpc_demo.public_ip
}

