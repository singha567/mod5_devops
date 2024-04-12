provider "aws" {
    profile = "default"
    region = "eu-west-2"
}
//comment
#comment

resource "aws_instance" "demo1" {
    ami = var.image_id #"ami-0fb391cce7a602d1f"    
    instance_type = var.instance_type 
    key_name = "mod50804" 
    /*
    user_data_replace_on_change = true
        user_data =<<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt install mysql-client -y
            EOF
            */


    tags = {
        Name = "made by terraform!!"      
    }
}

locals {
    project_name = "as"
}

resource "aws_instance" "demo2" {
    ami = "ami-0fb391cce7a602d1f"
    instance_type = "t2.nano"  

    tags = {
        Name = "made by terraform!!-${local.project_name}"      
    }
}
