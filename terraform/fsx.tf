resource "aws_fsx_windows_file_system" "ga_fsx" {
  active_directory_id           = aws_directory_service_directory.directory.id
  security_group_ids            = [data.aws_security_group.app.id]
  storage_capacity              = 32
  subnet_ids                    = [aws_subnets.app.ids[0]]
  throughput_capacity           = 32
  weekly_maintenance_start_time = "6:05:00"
}