# Terraform - how to securely deploy Azure resources

This Project contains all files for an attempt at the servian techChallengeApp infra deployment.

The approach is minimal using basic linux Centos vm deployment, utilized use of keyvault to store secrets and azure storage for state files etc. in an attempt to add some security. 

Upon provisioning it will take the IP of the host machine that ran the terraform script and add that to the nsg rules to limit access. Enabled ports for HTTP,HTTPS for testing and SSH for access.

Used bootstrap to prepare the vm for some prereqs used to running the golang techchallenge app and some test.

Main apps installed is golang for linux to run the techchallenge commands and lynx to test if the page is accessible.


## Content
This folder contains the following files:

| File | Description |
|------|-------------|
| README.md | this file |
| [backend.tf](./backend.tf) | Azure CLI script to create Azure AD service principal |
| [output.tf](./id_rsa) | Azure CLI script to create backend storage and Azure KeyVault to store storage account key |
| [main.tf](./main.tf) | Bash script to export environment variables |
| [script.sh](./script.sh) | Bash script to export environment variables |
| [variables.tf](./variables.tf) | holds variables |
| [providers.tf](./providers.tf) | holds declared variables |

Note: there will be other files that will be created(or have been created) depending on how you apply the terraform script.


## Prerequisites 
This assumes you already have a subscription for Azure

1. Install Terraform
2. Create Azure Service Principal (Optional - only needed if recreating the script from scratch) 
3. Create Azure keyvault and storage (Optional - only needed if recreating the script from scratch)


### 1. Install Terraform 
You can install terraform by following the instructions on the official docs.
https://developer.hashicorp.com/terraform/downloads


### 2. Create Azure Service Principal *Skip step*(Optional - only needed if recreating the script from scratch)
Follow instructions from the official docs 
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret


### 3. Create Azure Key vault *Skip step* (Optional - only needed if recreating the script from scratch)
You can execute the codes using bash/Azure Bash

1.1 Change values of the variable depending on what you want
 ```bash
    RESOURCE_GROUP_NAME=rnd
    STORAGE_ACCOUNT_NAME=tcastorageacc
    CONTAINER_NAME=tfstate
    VAULT_NAME=tcakeyvault
    SECRET_NAME=azureuser
```
1.2 Create a resource group to place the resources we will provision
 ```bash
az group create --name $RESOURCE_GROUP_NAME --location australiaeast
```

1.3 Create Storage account (will be used to hold the vm password)
 ```bash
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
```

1.4 Get Storage Account key
 ```bash
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv
```

1.4 Create Blob Container
 ```bash
 az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

    echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
    echo "container_name: $CONTAINER_NAME"
    echo "access_key: $ACCOUNT_KEY"
```

1.4 Create Keyvault
 ```bash
az keyvault create -g $RESOURCE_GROUP_NAME --name $VAULT_NAME 
```

1.4 Set Secret Value to storage account key
 ```bash
az keyvault secret set --vault-name $VAULT_NAME --name $SECRET_NAME --value $ACCOUNT_KEY
```

## Give secret permission access to service principal
You can follow instructions on the official docs for this step.
https://learn.microsoft.com/en-us/azure/key-vault/general/assign-access-policy?tabs=azure-portal


## Create the Resources with Terraform
go to command line or powershell go to the folder directory location of the terraform scripts

Initial terraform dependencies
 ```bash
terraform init -upgrade
```

Create execution plans
 ```bash
terraform plan -out main.tfplan
```

Apply created plan
 ```bash
terraform apply main.tfplan -auto-approve
```

Create private key if it hasn't been automatically created yet
 ```bash
terraform output -raw tls_private_key > id_rsa
```

Get public IP
 ```bash
terraform output public_ip_address
```

connect to the vm (password is admin123!)
 ```bash
ssh -i id_rsa azureuser@<public_ip_address>
```

Inside the vm go to root and set the path for golang to allow us to run the serve command
 ```bash
sudo -i
export PATH=$PATH:/usr/local/go/bin
```

Go to techchallenge app directory
 ```bash
cd /usr/local/golang/dist
```

Start serving request
 ```bash
sudo ./TechChallengeApp serve &
```

### Optional: test if webpage is up
Start serving request
 ```bash
lynx http://localhost:3000
```

exit vm
 ```bash
exit
```

set destroy flag
 ```bash
terraform plan -destroy -out main.destroy.tfplan
```

destroy/delete the resource
 ```bash
terraform apply main.destroy.tfplan
```

# Ideas for enhancement for running techchallenge serve 
1. Convert to systemctl service
2. Start service
3. install nginx
4. use port forward to allow access to the techchallenge page outside the vm via browser using public IP
