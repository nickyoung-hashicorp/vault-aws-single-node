# Vault Public IP Address
output "vault-ip" {
  value = aws_eip.vault.public_ip
}
