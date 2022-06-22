# Single Node - HashiCorp Vault
This example walks through deploying a single HashiCorp Vault instance on AWS EC2 with Terraform using both `file` and `remote-exec` provisioners.

## Requirements
This demonstration includes the following:
 - HashiCorp: Terraform `1.2.3`, Vault `latest`
 - AWS: EC2 and other supporting services
 - Packages: `jq`, `wget`, `unzip`

This walkthrough assumes you have valid AWS credentials (access and secret access keys).

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
```

Modify the `terraform.tfvars` if you wish to change the prefix, region, or any other variable's values.

Provision AWS infrastructure.
```
terraform init && terraform apply -auto-approve
```



## Configure Vault
SSH to the EC2 instance.
```sh
ssh -i ssh-key.pem ubuntu@$(terraform output -raw vault-ip)
```

The Vault service has already been installed and loaded as part of the provisioners.  This workflow walks through initializing, unsealing, and generating a root token.
```sh
export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=https://127.0.0.1:8200
vault operator init -format=json -key-shares=1 -key-threshold=1 > init.json
sleep 5
vault operator unseal $(cat init.json | jq -r '.unseal_keys_b64[0]')
sleep 2
cat init.json | jq -r '.root_token' > ~/root_token
export VAULT_TOKEN=$(cat root_token)
echo $VAULT_TOKEN
```
If you see a value that looks similar to `hvs.oaVqONptgd1Py0ewQJ8sSc5w`, you are logged in and can proceed with using a fresh instance of Vault.

## Clean Up

Exit the EC2 instance.
```sh
exit
```

Destroy infrastructure.
```sh
terraform destroy -auto-approve
```