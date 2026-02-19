resource "aws_ssm_association" "join_domain" {
  name        = "AWS-JoinDirectoryServiceDomain"
  targets {
    key    = "InstanceIds"
    values = [for instance in aws_instance.app : instance.id]
  }

  parameters = {
    directoryId       = aws_directory_service_directory.directory.id
    directoryName     = aws_directory_service_directory.directory.name
    dnsIpAddresses    = tolist(aws_directory_service_directory.directory.dns_ip_addresses)[0]
   }
}

# Cloudwatch agent installation and start
resource "aws_ssm_association" "install_cw_agent" {
  name        = "AWS-ConfigureAWSPackage"
  targets {
    key       = "tag:Monitoring"
    values    = ["enabled"]
  }
  parameters  = {
    action    = "Install"
    name      = "AmazonCloudWatchAgent"
  }
}

# Cloudwatch agent
locals {
  cwagent_windows_config = jsonencode({
    metrics = {
      namespace = "CWAgent"
      metrics_collected = {
        LogicalDisk = {
          measurement = [
            {name: "% Free Space", "unit": "Percent"}
          ]
          resources = ["*"]
        }
        Memory = {
          measurement = [
            {name: "% Committed Bytes In Use", "unit": "Percent"}
          ]
        }
      },
      append_dimensions = {
        InstanceId = "$${aws:InstanceId}"
        ImageId    = "$${aws:ImageId}"
        InstanceType = "$${aws:InstanceType}"
    }
  }
  })
  cwagent_name = "/GoAnywhere-${var.ENV}/ec2/amazon-cloudwatch-agent/config/windows"
}

resource "aws_ssm_parameter" "cwagent_config_windows" {
  name        = local.cwagent_name
  description = "CloudWatch Agent config for Windows instances"
  type        = "SecureString"
  value       = local.cwagent_windows_config
  tier        = "Standard"
}

resource "aws_ssm_association" "cwagent_start_windows_ssm_param" {
  name = "AWS-RunPowerShellScript"
  targets {
    key       = "tag:Monitoring"
    values    = ["enabled"]
  }
  schedule_expression = "rate(24 hours)"
  compliance_severity = "CRITICAL"
  parameters = {
    commands  = join("\n", [
      "$ctl = 'C:\\Program Files\\Amazon\\AmazonCloudWatchAgent\\amazon-cloudwatch-agent-ctl.ps1'",
      "& $ctl -a fetch-config -m ec2 -c ssm:${local.cwagent_name} -s"
    ])
  }
}