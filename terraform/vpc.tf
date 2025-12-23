data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["*"]
  }
}

resource "aws_vpc_dhcp_options" "ds" {
  domain_name          = aws_directory_service_directory.directory.name
  domain_name_servers  = aws_directory_service_directory.directory.dns_ip_addresses

  tags = {
    Name = "gonanywhere-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "assoc" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.ds.ids
}