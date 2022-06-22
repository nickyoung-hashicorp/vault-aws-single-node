# Single Node - HashiCorp Vault
This example walks through deploying a single HashiCorp Vault instance on AWS EC2 with Terraform using both `file` and `remote-exec` provisioners.

## Requirements
This demonstration includes the following:
 - HashiCorp: Terraform (1.2.3), Vault (10.3.1)
 - AWS: EC2
 - Packages: jq, wget, unzip
 - AWS Credentials (Access and Secret Access Keys)


## Deploy Vault on a single EC2 instance

Export / Save your AWS credentials.
```sh
export AWS_ACCESS_KEY_ID=<your-aws-access-key>
export AWS_SECRET_ACCESS_KEY==<your-aws-secret-key>
```

Clone repository and provision.
```sh
git clone https://github.com/nickyoung-hashicorp/vault-aws-single-node.git
cd vault-aws-single-node
terraform init && terraform apply -auto-approve
```

## Configure Vault
SSH to the EC2 instance
```sh
ssh -i ssh-key.pem ubuntu@$(terraform output vault-ip)
```

Update packages and install `jq`
```sh
sudo apt install jq -y
```

The Vault service has already been installed and loaded as part of the provisioners.  This workflow walks through initializing, unsealing, and generating a root token.
```sh
export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=http://127.0.0.1:8200
vault operator init -format=json -key-shares=1 -key-threshold=1 > init.json
sleep 5
vault operator unseal $(cat init.json | jq -r '.unseal_keys_b64[0]')
sleep 2
cat init.json | jq -r '.root_token' > /home/ubuntu/root_token
export VAULT_TOKEN=$(cat root_token)
echo $VAULT_TOKEN
```
Proceed to use Vault