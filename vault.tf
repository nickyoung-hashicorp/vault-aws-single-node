
resource "aws_instance" "vault" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.vault.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.a.id
  vpc_security_group_ids      = [aws_security_group.sg.id]

  tags = {
    Name = "${var.prefix}-vault-instance"
  }
}

resource "null_resource" "configure-vault" {
  depends_on = [aws_eip_association.vault]

  triggers = {
    build_number = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "sudo apt update -y",
      "sudo apt install unzip wget jq -y",
      "tput setaf 2; echo \"[TERRAFORM-REMOTE-EXEC] Completed package updates and installation!\"",
      "tput setaf 2; echo \"[TERRAFORM-REMOTE-EXEC] Install Vault OSS via apt...\"",
      "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
      "sudo apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
      "sudo apt-get update -y ",
      "sudo apt-get install vault -y",
      "tput setaf 2; echo \"[TERRAFORM-REMOTE-EXEC] Running binary: $(vault -v)\"",
      "sleep 2",
      "tput setaf 2; echo \"[TERRAFORM-REMOTE-EXEC] Starting Vault service...\"",
      "sudo systemctl start vault",
      "tput setaf 2; echo \"[TERRAFORM-REMOTE-EXEC] Vault installation complete!\"",
      "chmod +x /home/ubuntu/*.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.this.private_key_pem
      host        = aws_eip.vault.public_ip
    }
  }
}