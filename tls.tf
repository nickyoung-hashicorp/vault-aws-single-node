# Generates temporary SSH key pairs
resource "tls_private_key" "this" {
  algorithm = "RSA"
}

locals {
  private_key_filename = "ssh-key.pem"
}

resource "aws_key_pair" "vault" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.this.public_key_openssh
}

# Generate local PEM file
resource "local_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "ssh-key.pem"
  file_permission = "0600"
}