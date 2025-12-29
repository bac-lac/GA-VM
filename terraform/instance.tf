data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "app" {
  count                       = upper(var.MFT_CLUSTER) == "TRUE" ? 2 : 1
  ami                         = data.aws_ami.windows.id
  instance_type               = "r6i.large"
  key_name                    = aws_key_pair.instance_key.key_name
  vpc_security_group_ids      = [data.aws_security_group.app.id]
  subnet_id                   = element(data.aws_subnets.app.ids, count.index)
  get_password_data           = true
  user_data                   = local.windows_user_data
  monitoring                  = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  tags = {
    Name = "MFT-${count.index + 1}"
    OS   = "WindowsServer"
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted     = true
  }
}