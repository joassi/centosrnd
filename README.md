# Terraform - how to securely deploy Azure resources

This Project contains all files for my attempt at the servian techChallengeApp infra deployment.

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
2. Create Azure Service Principal 
3. Create Azure keyvault and storage


### 1. Install Terraform 
You can install terraform by following the instructions on the official docs.
https://developer.hashicorp.com/terraform/downloads


### 2. Create Azure Service Principal
Follow instructions from the official docs 
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret


### 3. Create Azure Key vault
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
terraform apply main.tfplan
```

Create private key if it hasn't been automatically created yet
 ```bash
terraform output -raw tls_private_key > id_rsa
```

Get public IP
 ```bash
terraform output public_ip_address
```

connect to the vm
 ```bash
ssh -i id_rsa azureuser@<public_ip_address>
```