resource "aws_dlm_lifecycle_policy" "default_ebs_snapshots" {
  description           = "Default EBS snapshot policy"
  execution_role_arn    = aws_iam_role.dlm.arn
  state                 = "ENABLED"
  policy_details {
    resource_types      = ["VOLUME"]
    schedule {
      name              = "ebs-snapshots"
      copy_tags         = true
      create_rule {
        interval        = var.DLM_INTERVAL
        interval_unit   = var.DLM_INTERVAL_UNIT
        times           = [var.DLM_START_TIME]
      }
      retain_rule {
        count           = var.DLM_RETENTION_DAYS
      }
      variable_tags {
        instance-id     = "$(instance-id)"
        timestamp       = "$(timestamp)"
      }
    }
    target_tags = {
      Snapshot          = "true"
    }
  }
  tags = {
    Name                = "default-ebs-snapshot-policy"
  }
}
