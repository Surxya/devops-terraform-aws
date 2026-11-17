variable "name" { type = string }
variable "vpc_id" { type = string }
variable "allowed_ssh_cidr" { type = string }

output "sg_id" {
  value = aws_security_group.web.id
}
