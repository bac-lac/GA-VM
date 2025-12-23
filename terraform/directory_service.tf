resource "aws_directory_service_directory" "directory" {
  name     = "bac-lac.local"
  password = var.DIRECTORY_ADMIN_PASSWORD
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = data.aws_vpc.vpc.id
    subnet_ids = slice(data.aws_subnet.app.id, 0, 2)
  }
}