output "public_ip" {
  value = module.web.public_ip
}

output "app_url" {
  value = "http://${module.web.public_ip}"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/tf-devops ubuntu@${module.web.public_ip}"
}
