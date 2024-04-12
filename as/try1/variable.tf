
variable "s3_bucket_name" {
    default = "as-bucket-demo-123"  
}

variable "instance_type" {
    default = "t2.micro"  
}

variable "image_id" {    
    default = "ami-0fb391cce7a602d1f"  
}

/*Variable attribute types:
- string: (an empty string is default)
- numbers: - can be null or 0.
- bool: (false could be empty)
- list: inidcated by [] comma separated items. Tuples too: ()
- map: dictionary {} - key value pairs
- null can be any.*/

# Validation
#The validation block allows you to define conditions that must be met

#Sensitive
#Marking a variable as sensitive - value will not be shown in outputs to cli

#Nullable .  Variable default to null

#Default - default value

/*variable "image_id"{
    type = string
    description = "The ID of the machine image (ami) to  use for the server"

    validation {
      condition = length(var.image_id) > 4 && substring(var.image_id,0,4) == "ami-"
      error_message = "The image id value must be longer than 4 and start with 'ami-' "
    }
}*/


