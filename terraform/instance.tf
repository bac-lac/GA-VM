resource "aws_instance" "app" {
  count                       = upper(var.MFT_CLUSTER) == "TRUE" ? 2 : 1
  ami                         = var.AMI_ID
  instance_type               = var.INSTANCE_TYPE
  key_name                    = aws_key_pair.instance_key.key_name
  vpc_security_group_ids      = [data.aws_security_group.app.id]
  subnet_id                   = element(data.aws_subnets.app.ids, count.index)
  get_password_data           = true
  monitoring                  = true
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  tags = {
    Name                      = "MFT-${count.index + 1}"
    PatchGroup                = "${count.index + 1}"
    Monitoring                = "enabled"
    Snapshot                  = "true"
  }
  metadata_options {
    http_endpoint             = "enabled"
    http_tokens               = "required"
  }
  root_block_device {
    encrypted                 = true
    iops                      = var.ROOT_VOLUME_IOPS
    throughput                = var.ROOT_VOLUME_THROUGHPUT
    volume_size               = var.ROOT_VOLUME_SIZE
    volume_type               = var.ROOT_VOLUME_TYPE
    tags = {
      Snapshot                = true
    }
  }
}