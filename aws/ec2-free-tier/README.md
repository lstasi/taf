# AWS EC2 Free Tier Module

Terraform module for deploying EC2 instances within AWS free tier limits.

## AWS Free Tier Limits

- **750 hours/month** of t2.micro (or t3.micro) for 12 months
- **30 GB** of EBS storage (gp2 or gp3)
- One instance can run continuously (730 hours/month)
- Multiple instances can share the 750 hours

## Features

- ✅ t2.micro/t3.micro instance types only
- ✅ Automatic AMI selection (Amazon Linux 2)
- ✅ Security group with configurable rules
- ✅ EBS encryption
- ✅ CloudWatch monitoring with CPU alarms
- ✅ Status check alarms
- ✅ Optional Elastic IP
- ✅ IMDSv2 enforced for security

## Usage

### Basic Example

```hcl
module "free_ec2" {
  source = "./aws/ec2-free-tier"
  
  instance_name = "my-free-server"
  vpc_id        = "vpc-xxxxx"
  subnet_id     = "subnet-xxxxx"
  key_name      = "my-keypair"
}
```

### Advanced Example

```hcl
module "web_server" {
  source = "./aws/ec2-free-tier"
  
  instance_name = "web-server"
  instance_type = "t2.micro"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  key_name      = "my-key"
  
  # Storage
  root_volume_size = 20  # GB
  root_volume_type = "gp3"
  enable_encryption = true
  
  # Security
  ingress_rules = [
    {
      description = "SSH from my IP"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["1.2.3.4/32"]
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  # Monitoring
  enable_cpu_alarm         = true
  cpu_threshold            = 80
  enable_status_check_alarm = true
  alarm_actions            = [module.billing_alerts.sns_topic_arn]
  
  # User data
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from Free Tier EC2!" > /var/www/html/index.html
  EOF
  
  tags = {
    Environment = "free-tier"
    Purpose     = "web-server"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_name | Name of the EC2 instance | `string` | `"free-tier-instance"` | no |
| instance_type | EC2 instance type (t2.micro or t3.micro) | `string` | `"t2.micro"` | no |
| ami_id | AMI ID (empty = latest Amazon Linux 2) | `string` | `""` | no |
| key_name | SSH key pair name | `string` | `""` | no |
| vpc_id | VPC ID | `string` | n/a | yes |
| subnet_id | Subnet ID | `string` | n/a | yes |
| root_volume_size | Root volume size in GB (8-30) | `number` | `8` | no |
| root_volume_type | Root volume type (gp2 or gp3) | `string` | `"gp3"` | no |
| enable_encryption | Enable EBS encryption | `bool` | `true` | no |
| enable_detailed_monitoring | Enable detailed monitoring | `bool` | `false` | no |
| user_data | User data script | `string` | `""` | no |
| iam_instance_profile | IAM instance profile | `string` | `""` | no |
| ingress_rules | Security group ingress rules | `list(object)` | SSH only | no |
| assign_elastic_ip | Assign Elastic IP | `bool` | `false` | no |
| enable_cpu_alarm | Enable CPU alarm | `bool` | `true` | no |
| cpu_threshold | CPU threshold percentage | `number` | `80` | no |
| enable_status_check_alarm | Enable status check alarm | `bool` | `true` | no |
| alarm_actions | SNS topic ARNs for alarms | `list(string)` | `[]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | EC2 instance ID |
| instance_arn | EC2 instance ARN |
| instance_state | Instance state |
| public_ip | Public IP address |
| private_ip | Private IP address |
| public_dns | Public DNS name |
| private_dns | Private DNS name |
| elastic_ip | Elastic IP (if assigned) |
| security_group_id | Security group ID |
| security_group_name | Security group name |
| ssh_command | SSH connection command |
| instance_hours_per_month | Hours per month info |

## Important Notes

### Free Tier Limits

⚠️ **750 hours total per month across all t2.micro/t3.micro instances**

- One instance continuously = 730 hours ✅
- Two instances continuously = 1460 hours ❌ (exceeds limit)
- Two instances 50% uptime = 730 hours ✅

### Region Considerations

- **t2.micro**: Available in most regions
- **t3.micro**: Available in newer regions, may replace t2.micro
- Check your region's free tier offerings

### Cost Warnings

Additional charges occur for:
- ❌ **Elastic IPs** not attached to running instances ($0.005/hour)
- ❌ **Data transfer** out beyond 100GB/month
- ❌ **Additional EBS volumes** beyond 30GB
- ❌ **Snapshots** (not included in free tier)
- ❌ **NAT Gateway** data processing

### Security Best Practices

1. **Restrict SSH**: Limit SSH to your IP only
   ```hcl
   ingress_rules = [{
     description = "SSH from my IP"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["YOUR_IP/32"]  # Replace with your IP
   }]
   ```

2. **Use SSH Keys**: Always specify `key_name` for secure access

3. **Enable Encryption**: Keep `enable_encryption = true`

4. **IMDSv2**: Enforced by default for metadata security

5. **IAM Roles**: Use IAM instance profiles instead of access keys

### Monitoring

The module includes:
- **CPU Utilization Alarm**: Alerts at 80% (configurable)
- **Status Check Alarm**: Alerts on instance failures
- **CloudWatch Metrics**: Basic monitoring included in free tier

Connect alarms to billing-alerts SNS topic:
```hcl
alarm_actions = [module.billing_alerts.sns_topic_arn]
```

## Examples

### Web Server

See [examples/web-server/](examples/web-server/) for a complete web server setup.

### Development Environment

See [examples/dev-environment/](examples/dev-environment/) for a development workstation.

## Connecting to Your Instance

### SSH Connection

```bash
# Get the SSH command from outputs
terraform output ssh_command

# Or manually:
ssh -i ~/.ssh/your-key.pem ec2-user@<public-ip>
```

### Using Systems Manager

For keyless access (requires IAM role):
```bash
aws ssm start-session --target <instance-id>
```

## Troubleshooting

### Can't Connect via SSH

1. Check security group allows port 22 from your IP
2. Verify key pair permissions: `chmod 400 ~/.ssh/key.pem`
3. Check instance is in running state
4. Verify public IP is assigned (needs public subnet)

### Instance Not Starting

1. Check AWS service health dashboard
2. Verify subnet has available IPs
3. Check instance limits in your region
4. Review CloudWatch logs

### High Costs

1. Verify only one t2.micro/t3.micro running
2. Check for unattached Elastic IPs
3. Review data transfer costs
4. Ensure no additional EBS volumes

## Related Modules

- [billing-alerts](../billing-alerts/) - Deploy this first!
- [vpc-free-tier](../vpc-free-tier/) - VPC and networking
- [s3-free-tier](../s3-free-tier/) - Object storage

## Further Reading

- [AWS EC2 Free Tier](https://aws.amazon.com/free/)
- [EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [Instance Types](https://aws.amazon.com/ec2/instance-types/)

---

**Remember**: Deploy [billing-alerts](../billing-alerts/) first! 🛡️
