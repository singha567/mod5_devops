provider "aws" {
  profile = "default"
  region     = "eu-west-2"
}

resource "aws_instance" "demo1" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = "TF_key"
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]

    tags = {
        project = var.project_name
    }

    depends_on = [aws_key_pair.TF_key]
}

resource "aws_s3_bucket" "s3bucket" {
    bucket = var.s3_bucket_name
}

resource "aws_security_group" "allow_ssh" {
    name = var.security_group_name
    description = "allow ssh access"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        project = var.project_name
    }
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


