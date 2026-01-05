resource "aws_ssm_parameter" "dir_admin_password" {
  name        = "/goanywhere/ad/admin_password"
  type        = "SecureString"
  value       = var.DIRECTORY_ADMIN_PASSWORD
  description = "Directory Admin password"
}


resource "aws_ssm_association" "join_domain" {
  name        = "AWS-JoinDirectoryServiceDomain"
  targets {
    key    = "InstanceIds"
    values = [for instance in aws_instance.app : instance.id]
  }

  parameters = {
    directoryId       = aws_directory_service_directory.directory.id
    directoryName     = aws_directory_service_directory.directory.name
   }
}

############################################################################
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
      values = ["CRITICAL", "IMPORTANT"]
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
      values = ["CRITICAL", "IMPORTANT"]
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
  count = 2
  
  name        = "GoAnywhere-${var.ENV}-${index.count + 1}"
  description = "Patchgroup ${index.count + 1}"

  configuration_definition {
    local_deployment_administration_role_arn = "arn:aws:iam::${var.ACCOUNT}:role/AWS-QuickSetup-PatchPolicy-LocalAdministrationRole"
    local_deployment_execution_role_name     = "AWS-QuickSetup-PatchPolicy-LocalExecutionRole"

    type = "AWSQuickSetupType-PatchPolicy"
    parameters = {
      ConfigurationOptionsInstallNextInterval = "true"
      ConfigurationOptionsInstallValue        = "cron(0 ${index.count + 4} ? * SAT#${locals.sat} *)"
      ConfigurationOptionsPatchOperation      = "ScanAndInstall"
      ConfigurationOptionsScanNextInterval    = "false"
      ConfigurationOptionsScanValue           = "cron(00 23 * * ? *)"
      IsPolicyAttachAllowed                   = "true"

      OutputBucketRegion   = "ca-central-1"
      OutputLogEnableS3    = "true"
      OutputS3BucketName   = "${aws_s3_bucket.ssm_s3.id}"
      OutputS3KeyPrefix    = "${var.ENV}-${index.count + 1}"

      PatchBaselineRegion  = "ca-central-1"
      PatchBaselineUseDefault = "custom"
      PatchPolicyName      = "GoAnywhere-${var.ENV}-${index.count + 1}"

      RateControlConcurrency   = "100%"
      RateControlErrorThreshold = "33%"

      RebootOption = "RebootIfNeeded"

      SelectedPatchBaselines = local.selected_patch_baselines_json

      TargetAccounts = "685264686784"
      TargetRegions  = "ca-central-1"
      TargetTagKey   = "PatchGroup"
      TargetTagValue = "${index.count + 1}"
      TargetType     = "Tags"
    }
  }
}