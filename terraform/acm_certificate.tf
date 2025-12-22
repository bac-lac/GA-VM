resource "aws_acm_certificate" "baclacgcca" {
  private_key       = "${var.CERT_PRIVATE_KEY}"
  certificate_body  = "${var.CERT_BODY}"
  certificate_chain = "${var.CERT_CHAIN}"

  lifecycle {
    create_before_destroy = true
  }
}