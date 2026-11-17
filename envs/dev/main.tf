locals {
  name = "${var.project}-${var.env}"
}

module "vpc" {
  source             = "../../modules/vpc"
  name               = local.name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  az                 = var.az
}

module "security" {
  source           = "../../modules/security"
  name             = local.name
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = var.my_ip_cidr
}

module "web" {
  source        = "../../modules/ec2"
  name          = local.name
  subnet_id     = module.vpc.public_subnet_id
  sg_ids        = [module.security.sg_id]
  instance_type = var.instance_type
  public_key    = file(pathexpand(var.public_key_path))
  user_data     = templatefile("${path.module}/user_data.sh.tpl", { app_image = var.app_image })
}

resource "aws_sns_topic" "alerts" {
  name = "${local.name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "CPU above 70% for 5 minutes"
  dimensions = {
    InstanceId = module.web.instance_id
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
