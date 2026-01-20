resource "aws_secretsmanager_secret" "ssh_private" {
  name       = "ssh/private-key"
}

resource "aws_secretsmanager_secret_version" "ssh_private_version" {
  secret_id     = aws_secretsmanager_secret.ssh_private.id
  secret_string = tls_private_key.key.private_key_pem
}