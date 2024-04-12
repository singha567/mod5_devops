output "vm_public_ip2" {
 value = aws_instance.demo1.public_ip
}
/*
output "s3_public_ip" {
 value = aws_s3_bucket.s3bucket.bucket_domain_name
}*/
output "vm_public_ip" {
        value = aws_instance.demo1.public_ip
}