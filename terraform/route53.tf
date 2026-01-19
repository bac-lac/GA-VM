resource "aws_route53_zone" "private" {
  name = "bac-lac.local"

  vpc {
    vpc_id = data.aws_vpc.vpc.id
  }

  comment = "Private zone for internal services"
}

resource "aws_route53_record" "fsx_cname" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "fileshare.bac-lac.local"
  type    = "CNAME"
  ttl     = 300

  records = [aws_fsx_windows_file_system.ga_fsx.dns_name]
}