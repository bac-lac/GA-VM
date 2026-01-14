# RDS IAM ROLE
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
}

resource "aws_iam_role_policy_attachment" "rds_attach" {
  role       = aws_iam_role.ga_rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# SSM IAM ROLE
resource "aws_iam_role" "ssm_role" {
  name          = "SSMRole-${var.ENV}"
  description   = "Provides access to EC2 for SSM"
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

resource "aws_iam_role_policy_attachment" "cwagent_server" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

##### SSM S3 bucket roles and policies #####
data "aws_iam_policy_document" "patchpolicy_get_object" {
  statement {
    sid     = "AllowGetObjectFromQuickSetupPatchPolicyBuckets"
    effect  = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::aws-quicksetup-patchpolicy-*/*",
    ]
  }
}

resource "aws_iam_policy" "s3_get_object_policy" {
  name        = "aws-quicksetup-patchpolicy-baselineoverrides-s3"
  description = "Allow GetObject on aws-quicksetup-patchpolicy-* buckets"
  policy      = data.aws_iam_policy_document.patchpolicy_get_object.json
}

data "aws_iam_policy_document" "ssm_s3_permissions" {
  version = "2012-10-17"

  statement {
    sid     = "AllowOnlySSMRolesToReadWrite"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.ssm_s3.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.ssm_role.arn}"]
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      "${aws_s3_bucket.ssm_s3.arn}",
      "${aws_s3_bucket.ssm_s3.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "ssm_s3_policy" {
  bucket = aws_s3_bucket.ssm_s3.id
  policy = data.aws_iam_policy_document.ssm_s3_permissions.json
}

# SSM QUICKSETUP ROLES
resource "aws_iam_role" "ssm_qs_exec_role" {
  name          = "AWS-QuickSetup-GA-LocalExecutionRole-${var.ENV}"
  description   = "Provides access to QuickSetup execution role for SSM"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "AWS": "arn:aws:iam::${var.ACCOUNT}:role/AWS-QuickSetup-GA-LocalAdministrationRole"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_qs_exec_attach" {
  role       = aws_iam_role.ssm_qs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSQuickSetupPatchPolicyDeploymentRolePolicy"
}

resource "aws_iam_role" "ssm_qs_admin_role" {
  name          = "AWS-QuickSetup-GA-LocalAdministrationRole-${var.ENV}"
  description   = "Provides access to QuickSetup admin role for SSM"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect": "Allow",
        "Principal": {
            "Service": "cloudformation.amazonaws.com"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
            "StringEquals": {
                "aws:SourceAccount": "${var.ACCOUNT}"
            },
            "StringLike": {
                "aws:SourceArn": "arn:aws:cloudformation:*:${var.ACCOUNT}:stackset/AWS-QuickSetup-*"
            }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "ssm_qs_admin_permissions" {
  version = "2012-10-17"
  statement {
    Action = [
        "sts:AssumeRole"
    ],
    Resource = "arn:aws:iam::${var.ACCOUNT}:role/AWS-QuickSetup-GA-LocalExecutionRole",
    Effect = "Allow"
  }
}

resource "aws_iam_policy" "qs_admin_policy" {
  name        = "AWS-QuickSetup-GA-LocalAdministrationRole-policy-${var.ENV}"
  description = "Permissions for Quick Setup local admin role"
  policy      = data.aws_iam_policy_document.ssm_qs_admin_permissions.json
}

resource "aws_iam_role_policy_attachment" "qs_admin_attach" {
  role       = aws_iam_role.ssm_qs_admin_role.name
  policy_arn = aws_iam_policy.qs_admin_policy.arn
}

# DLM IAM ROLE
resource "aws_iam_role" "dlm" {
  name                = "dlm-default-ebs-snapshot-role"
  description         = "Provides access to EC2 for DLM"
  assume_role_policy  = jsonencode({
    Version           = "2012-10-17",
    Statement = [{
      Effect          = "Allow",
      Principal       = { Service = "dlm.amazonaws.com" },
      Action          = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dlm_attach" {
  role       = aws_iam_role.dlm.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}