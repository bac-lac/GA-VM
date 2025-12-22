data "aws_iam_policy_document" "ga_rds_monitoring_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ga_rds_monitoring_role" {
  name                = "ga_rds_monitoring_role-${var.ENV}"
  description         = "Provides access to Cloudwatch for RDS Enhanced Monitoring"
  assume_role_policy  = data.aws_iam_policy_document.ga_rds_monitoring_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
}

data "aws_iam_policy_document" "ga_sns_topic_access_policy" {
  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers  = ["*"]
    }
    resources = [
      aws_sns_topic.ga_sns_topic.arn
    ]
    condition {
      test = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        "${var.ACCOUNT}"
      ]
    }
    sid = "default_policy"
  }
  statement {
    actions = ["SNS:Publish"]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers  = ["cloudwatch.amazonaws.com"]
    }
    resources = [
      data.aws_kms_alias.ga_kms_main.target_key_arn
    ]
    sid = "Allow_Publish_Alarms"
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}