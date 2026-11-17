variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "project" {
  type    = string
  default = "devops-demo"
}
variable "env" {
  type    = string
  default = "dev"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "az" {
  type    = string
  default = "ap-south-1a"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "public_key_path" {
  type    = string
  default = "~/.ssh/tf-devops.pub"
}
variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR form, e.g. 49.37.1.2/32"
}
variable "app_image" {
  type        = string
  description = "Docker image, e.g. surya/devops-demo-app:1.0"
}
variable "alert_email" {
  type        = string
  description = "Email for CloudWatch alarm notifications"
}
