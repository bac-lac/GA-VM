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

# SSM Patching
resource "aws_ssm_patch_baseline" "patch_baseline" {
  name            = "BAC-WindowsPatchBaseline-OS-Applications"
  operating_system = "WINDOWS"
  description     = "For the Windows Server operating system, approves all patches that are classified as CriticalUpdates or SecurityUpdates and that have an MSRC severity of Critical or Important. For Microsoft applications, approves all patches. Patches are auto-approved two days after release."

  approval_rule {
    approve_after_days = 2

    patch_filter {
      key    = "PATCH_SET"
      values = ["OS"]
    }

    patch_filter {
      key    = "MSRC_SEVERITY"
      values = ["Important", "Critical"]
    }
    
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["SecurityUpdates", "CriticalUpdates"]
    }
  }

  approval_rule {
    approve_after_days = 2

    patch_filter {
      key    = "PATCH_SET"
      values = ["APPLICATION"]
    }

    patch_filter {
      key    = "MSRC_SEVERITY"
      values = ["Important", "Critical"]
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["SecurityUpdates", "CriticalUpdates"]
    }
  }
}
locals {
  selected_patch_baselines_json = jsonencode({
    "WINDOWS" = {
      value       = aws_ssm_patch_baseline.patch_baseline.id
      label       = aws_ssm_patch_baseline.patch_baseline.name
      description = aws_ssm_patch_baseline.patch_baseline.description
      disabled    = false
    }
  })
  sat = var.ENV == "prod" ? 4 : 3
}

resource "aws_ssmquicksetup_configuration_manager" "goanywhere_ssm" {
  count       = upper(var.MFT_CLUSTER) == "TRUE" ? 2 : 1
  
  name        = "GoAnywhere-${var.ENV}-${count.index + 1}"
  description = "Patchgroup ${count.index + 1}"

  configuration_definition {
    local_deployment_administration_role_arn = aws_iam_role.ssm_qs_admin_role.arn
    local_deployment_execution_role_name     = aws_iam_role.ssm_qs_exec_role.name

    type = "AWSQuickSetupType-PatchPolicy"
    parameters = {
      ConfigurationOptionsInstallNextInterval = "true"
      ConfigurationOptionsInstallValue        = "cron(0 ${count.index + 4} ? * SAT#${local.sat} *)"
      ConfigurationOptionsPatchOperation      = "ScanAndInstall"
      ConfigurationOptionsScanNextInterval    = "false"
      ConfigurationOptionsScanValue           = "cron(00 23 * * ? *)"
      IsPolicyAttachAllowed                   = "true"

      OutputBucketRegion   = "ca-central-1"
      OutputLogEnableS3    = "true"
      OutputS3BucketName   = "${aws_s3_bucket.ssm_s3.id}"
      OutputS3KeyPrefix    = "${var.ENV}-${count.index + 1}"

      PatchBaselineRegion  = "ca-central-1"
      PatchBaselineUseDefault = "custom"
      PatchPolicyName      = "GoAnywhere-${var.ENV}-${count.index + 1}"

      RateControlConcurrency   = "100%"
      RateControlErrorThreshold = "33%"

      RebootOption = "RebootIfNeeded"

      SelectedPatchBaselines = local.selected_patch_baselines_json

      TargetAccounts = "${var.ACCOUNT}"
      TargetRegions  = "ca-central-1"
      TargetTagKey   = "PatchGroup"
      TargetTagValue = "${count.index + 1}"
      TargetType     = "Tags"
    }
  }
  depends_on  = [aws_iam_role_policy_attachment.ssm_qs_exec_attach, aws_iam_role_policy_attachment.qs_admin_attach, aws_fsx_windows_file_system.ga_fsx]
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
    agent: {
    metrics_collection_interval: 60,
    logfile: "c:\\ProgramData\\Amazon\\AmazonCloudWatchAgent\\Logs\\amazon-cloudwatch-agent.log"
    },
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
            {name: "Available MBytes", "unit": "Megabytes"}
          ]
        }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path: "c:\\ProgramData\\Amazon\\AmazonCloudWatchAgent\\Logs\\amazon-cloudwatch-agent.log",
              log_group_name: "amazon-cloudwatch-agent",
              log_stream_name: "amazon-cloudwatch-agent-{instance_id}-{local_hostname}",
              timezone: "UTC"
            }
          ]
        }
      }
    },
    log_stream_name: "log_stream_name"
  })
}

resource "aws_ssm_parameter" "cwagent_config_windows" {
  name        = "/GoAnywhere-${var.ENV}/ec2/amazon-cloudwatch-agent/config/windows"
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
  # Optional: re-run periodically to enforce state (idempotent)
  schedule_expression = "rate(30 minutes)"

  # This is the Run Command parameter schema for AWS-RunPowerShellScript
  parameters = {
    commands = [
      "& 'C:\\Program Files\\Amazon\\AmazonCloudWatchAgent\\amazon-cloudwatch-agent-ctl.ps1' -a fetch-config -m ec2 -c ssm:/GoAnywhere-${var.ENV}/ec2/amazon-cloudwatch-agent/config/windows -s"
    ]
  }

  compliance_severity = "CRITICAL"
}
