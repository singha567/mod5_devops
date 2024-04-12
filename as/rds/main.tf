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

resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0fb391cce7a602d1f"
  instance_type          = "t2.micro"
  key_name               = "TF_key"
  user_data_replace_on_change = true
    user_data  = <<-EOF
        #!/bin/bash
        sudo apt-get update -y 
        sudo apt install mysql-client -y
        EOF

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  depends_on             = [aws_key_pair.TF_key]
}

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

output "ec2_public_ip_for_mysql" {
  value = aws_instance.ec2_instance.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}
