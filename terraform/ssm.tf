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
    values = [aws_instance.app[0].id, aws_instance.app[1].id]
  }

  parameters = {
    directoryId       = aws_directory_service_directory.directory.id
    directoryName     = aws_directory_service_directory.directory.name
   }
}