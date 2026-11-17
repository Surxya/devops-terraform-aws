variable "name" { type = string }
variable "subnet_id" { type = string }
variable "sg_ids" { type = list(string) }
variable "public_key" { type = string }
variable "user_data" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
