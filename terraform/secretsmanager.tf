resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "ssh_private" {
  name       = "ec2/key-pair-${var.env}-${random_id.suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "ssh_private_version" {
  secret_id     = aws_secretsmanager_secret.ssh_private.id
  secret_string = tls_private_key.key.private_key_pem
}