resource "aws_fsx_windows_file_system" "ga_fsx" {
  active_directory_id           = aws_directory_service_directory.directory.id
  security_group_ids            = [data.aws_security_group.app.id]
  storage_capacity              = var.FSX_STORAGE_CAPACITY
  subnet_ids                    = [data.aws_subnets.app.ids[0]]
  throughput_capacity           = var.FSX_THROUGHPUT_CAPACITY
  weekly_maintenance_start_time = "6:05:00"
  tags = {
      Name                      = "GoAnywhere-${var.ENV}"
    }
}