/**
 * AWS EC2 Free Tier Module
 * 
 * Creates EC2 instances within AWS free tier limits:
 * - 750 hours/month of t2.micro (or t3.micro) for 12 months
 * - Includes monitoring, security groups, and automatic shutdown options
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Get latest Amazon Linux 2 AMI if not specified
data "aws_ami" "amazon_linux_2" {
  count = var.ami_id == "" ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for the instance
resource "aws_security_group" "instance" {
  name_prefix = "${var.instance_name}-sg-"
  description = "Security group for ${var.instance_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.instance_name}-sg"
      ManagedBy = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 instance
resource "aws_instance" "free_tier" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2[0].id
  instance_type = var.instance_type

  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance.id]
  subnet_id              = var.subnet_id
  
  # Free tier includes 30 GB of EBS storage
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.enable_encryption
    delete_on_termination = true

    tags = merge(
      var.tags,
      {
        Name      = "${var.instance_name}-root"
        ManagedBy = "Terraform"
      }
    )
  }

  # Enable detailed monitoring (within free tier limits)
  monitoring = var.enable_detailed_monitoring

  # User data script
  user_data = var.user_data != "" ? var.user_data : null

  # IAM instance profile
  iam_instance_profile = var.iam_instance_profile

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Enforce IMDSv2
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.tags,
    {
      Name      = var.instance_name
      FreeTier  = "true"
      ManagedBy = "Terraform"
    }
  )

  lifecycle {
    ignore_changes = [
      ami,  # Prevent replacement on AMI updates
    ]
  }
}

# CloudWatch alarm for high CPU usage
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_cpu_alarm ? 1 : 0

  alarm_name          = "${var.instance_name}-high-cpu"
  alarm_description   = "Alert when CPU utilization is high on ${var.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.free_tier.id
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name      = "${var.instance_name}-high-cpu"
      ManagedBy = "Terraform"
    }
  )
}

# Optional: CloudWatch alarm for instance status check failures
resource "aws_cloudwatch_metric_alarm" "instance_check" {
  count = var.enable_status_check_alarm ? 1 : 0

  alarm_name          = "${var.instance_name}-status-check"
  alarm_description   = "Alert when instance status check fails on ${var.instance_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.free_tier.id
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name      = "${var.instance_name}-status-check"
      ManagedBy = "Terraform"
    }
  )
}

# Elastic IP (optional, but note: unattached EIPs incur charges!)
resource "aws_eip" "instance" {
  count = var.assign_elastic_ip ? 1 : 0

  instance = aws_instance.free_tier.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name      = "${var.instance_name}-eip"
      ManagedBy = "Terraform"
    }
  )

  depends_on = [aws_instance.free_tier]
}
