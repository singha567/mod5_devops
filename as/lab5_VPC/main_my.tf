resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "EC2 security group"

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

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "RDS security group"
}
/*
resource "aws_security_group_rule" "ec2_to_rds" {
  security_group_id        = aws_security_group.ec2_sg.id
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_sg.id
}

resource "aws_security_group_rule" "rds_to_ec2" {
  security_group_id        = aws_security_group.rds_sg.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
}
*/
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

resource "aws_vpc" "as-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = "true" #gives you an internal host name
}

resource "aws_subnet" "pub-subnet1" {
    vpc_id = "${aws_vpc.as-vpc.id}"
    cidr_block = "10.10.0.0/20"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-2a"
}

resource "aws_subnet" "pub-subnet2" {
    vpc_id = "${aws_vpc.as-vpc.id}"
    cidr_block = "10.10.0.0/20"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-2a"
}

resource "aws_internet_gateway" "as-igw" {
    vpc_id = "${aws_vpc.as-vpc.id}"
}

resource "aws_route_table" "as-route" {
    vpc_id = "${aws_vpc.as-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.as-igw.id}" 
    }
}

resource "aws_route_table_association" "as-routeass1"{
    subnet_id = "${aws_subnet.pub-subnet1.id}"
    route_table_id = "${aws_route_table.as-route.id}"
}

resource "aws_route_table_association" "as-routeass2"{
    subnet_id = "${aws_subnet.pub-subnet2.id}"
    route_table_id = "${aws_route_table.as-route.id}"
}

resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  key_name               = "TF_key"
  subnet_id = "${aws_subnet.pub-subnet1.id}"  # VPC
 /* user_data_replace_on_change = true
    user_data  = <<-EOF
        #!/bin/bash
        sudo apt-get update -y 
        sudo apt install mysql-client -y
        EOF
*/
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  depends_on             = [aws_key_pair.TF_key]
}

/*
resource "aws_db_subnet_group" "subnet_group" {
  name       = "my-subnet-group"
  subnet_ids = ["subnet-034dc62be04865899", "subnet-0b4cbfc541c8a1e81", "subnet-00836672941282aea"]
}

resource "aws_db_instance" "db_instance" {
  engine                  = "mysql"
  engine_version = "8.0.35"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "password"
  allocated_storage       = 20
  storage_type            = "gp2"
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
}
*/

output "ec2_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "vpc_id" {
  value = aws_vpc.as-vpc.id
}

output "subnet_ids_1" {
  value = aws_subnet.pub-subnet1.id
}

output "subnet_ids_2" {
  value = aws_subnet.pub-subnet2.id
}