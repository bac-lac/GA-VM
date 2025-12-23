resource "aws_ssm_parameter" "dir_admin_password" {
  name        = "/goanywhere/ad/admin_password"
  type        = "SecureString"
  value       = var.DIRECTORY_ADMIN_PASSWORD
  description = "Directory Admin password"
}
