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
  count                       = 3
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

locals {
  windows_user_data = <<-EOF
    <powershell>
      # Enable IIS
      Install-WindowsFeature -Name Web-Server -IncludeManagementTools

      # Get EC2 instance ID
      [string]$token = (Invoke-WebRequest -Headers @{'X-aws-ec2-metadata-token-ttl-seconds' = '21600'} ` -Method PUT -Uri 'http://169.254.169.254/latest/api/token' -UseBasicParsing).Content
      $jsonString = (Invoke-WebRequest -Headers @{'X-aws-ec2-metadata-token' = $token} ` -Uri 'http://169.254.169.254/latest/dynamic/instance-identity/document' -UseBasicParsing).Content
      $object = $jsonString | ConvertFrom-Json
      $instanceId = Write-Output $object.instanceId

      # Write a simple page
      $content = "<html><body><h1>Hello from $instanceId</h1><p>IIS on Windows Server v2</p></body></html>"
      $path = "C:\\inetpub\\wwwroot\\Default.htm"
      Set-Content -Path $path -Value $content -Encoding UTF8

      # Ensure IIS starts
      Start-Service W3SVC
      Set-Service -Name W3SVC -StartupType Automatic
    </powershell>
  EOF
}
