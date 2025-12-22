
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
  count                       = 2
  ami                         = data.aws_ami.windows.id
  instance_type               = "r6i.large"
  key_name                    = "keypair"
  vpc_security_group_ids      = [data.aws_security_group.app.id]
  subnet_id                   = element(data.aws_subnets.app.ids, count.index)
  get_password_data           = false
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
}


locals {
  windows_user_data = <<-EOF
    <powershell>
      # Enable IIS
      Install-WindowsFeature -Name Web-Server -IncludeManagementTools

      # Get EC2 instance ID
      $instanceId = (Invoke-WebRequest -UseBasicParsing -Uri http://169.254.169.254/latest/meta-data/instance-id).Content

      # Write a simple page
      $content = "<html><body><h1>Hello from $instanceId</h1><p>IIS on Windows Server</p></body></html>"
      $path = "C:\\inetpub\\wwwroot\\Default.htm"
      Set-Content -Path $path -Value $content -Encoding UTF8

      # Ensure IIS starts
      Start-Service W3SVC
      Set-Service -Name W3SVC -StartupType Automatic
    </powershell>
  EOF
}
