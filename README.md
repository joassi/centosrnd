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
| [variables.tf](./variables.tf) | Bash script to export environment variables |
| [providers.tf](./providers.tf) | Bash script to export environment variables |
Note: there will be other files that will be created(or have been created) depending on how you apply the terraform script.

## Prerequisites
This assumes you already have a subscription for Azure

1. Install Terraform
2. Create Azure Service Principal 
3. Create Azure keyvault
4. Create Azure Storage

### 1. Install Terraform 
You can install terraform by following the instructions on the official docs.
https://developer.hashicorp.com/terraform/downloads


### 2. Create Azure Service Principal
Follow instructions from the official docs 
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret


### 3. Create Azure Key vault
You can execute the codes using bash/Azure Bash
1.1 Change values of the variable depending on what you want 
    RESOURCE_GROUP_NAME=rnd
    STORAGE_ACCOUNT_NAME=tcastorageacc
    CONTAINER_NAME=tfstate
    VAULT_NAME=tcakeyvault
    SECRET_NAME=azureuser

1.2 Create a resource group to place the resources we will provision
 ```bash
az group create --name $RESOURCE_GROUP_NAME --location eastaustralia
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

CREATE AWES EC2 INSTANCE WITH TERRAFORM
This will encompass task number 1-7
1. Prepare some prerequisites 
   a. Created an aws user account(Type = Access key - Programmatic access) with enough permission provision resources
   b. Create key pair (Type = .pem incase needed for some purpose)
   c. Create/convert the pem to ppk through putty gen

2. Prepare workspace folder for all terraform files that will be used for the provisioning of this resource. Files consists of 4 main items. 
   main.tf       = where providers will be declared together with access keys
   resources.tf  = where main scripts for resource provisioning will be 
   variables.tf  = as name suggest place to put variables
   scripf.sh     = where we will place startup scripts for the provisioned instance.

   Notes:
    -Created separate files even if it can be put into one is it makes it easier for myself to read, looks a lot less messy. 
    - (TASK no.1) used variables for AWS credentials and Region due to requirement on needing those inputed during deployment, also used variables on some of the parameters coz its easier for me to edit values in a single place during my tests

3. Create the TF Script for resource provisioning.
   -in summary I did some tests doing things manually through aws portal to get the gist of things co'z I haven't used aws before. 
   
   Used Terraform docs as reference to compose the TF scripts. 
   
   Included a few depends_on declaration on some resource just to avoid errors of provisioning before dependencies. 

   What the TF script does
   - (TASK no.2) create a new vpc which is later assigned to the aws instance 
   - (TASK no.3) create a ec2 instance t2 using ubuntu image 
   - (TASK no.4) create a security group with egress for anywhere and ingress for SSH(22) and http(80) allow for my IP address only. 
   - added user_data referencing a bash file on the aws instance provisioning part. This is for running start up scipts.

   What the startup script does
   - (TASK no.5) enable ubuntu fire wall and add rules to allow ssh and http access from my IP 
   - (TASK no.6) Install docker CE
   - (TASK no.7) Deploy Nginx and run , apply healthcheck on the run statement for later use.
   - install more utils for timestamp that will be used later
   - installed other tools I used for testing

RUN AUTOMATION TO PROVISION AWS EC2 INSTANCE. 
1. make sure you are in the folder where the TF resources are, run the Terraform init commant to download all dependencies.
2. Run terraform validate to check if there are no issues.
2.2 Optional - Terraform plan to check the would be output.
3. Run "Terraform -apply -var "aws_secret=<secret key>" -var "aws_clientid=<client id>" -var "aws_region=<aws region>"

CONNECT TO THE AWS EC2 INSTANCE
1. Open Putty go to Connection > SSH > Auth > Credentials then click Browse under "Private key file for authentication" and locate your ppk file.
2. Go back to session input the public up or public DNS from the ec2 instance in AWS. You can click Connect in the instance summary page and click ssh as well to get the value you need to past to "host name (or IP address)" field on putty session tab. (optionally you can save for future use) Click open
3. Login with whatever user name you've set, by default , ubuntu uses "ubuntu".

EXECUTE SCRIPT FOR LOG HEALTHSTATUS and RESOURCE USAGE
Note: initially I had intended to include this in the automation, but after a couple of hours of test and research it doesn't work if I include it on the startup script, I thought about creating a separate TF script to run once instance has been provisioned but I found from some articles that scripts can only be run on newly created instances not existing ones (I may be wrong). 

1. Once you have access to the terminal(following steps above) run the scripts below.
  -(TASK 8.a) Creates a job that saves output of a docker function displaying  resource usage info on resource.log including "ts" to prepend timestamps on the output 
  while true; do sleep 10; sudo docker stats --no-stream ngjohnx | ts '[%Y-%m-%d %H:%M:%S]' >> resource.log; done &
  
  -(TASK 8.a) Creates a job that saves output of docker ps that has healthcheck on resource.log, including "ts" to prepend timestamps on the output 
  while true; do sleep 10; sudo docker ps ngjohnx -s | ts '[%Y-%m-%d %H:%M:%S]' >> resource.log; done &




RISK (TASK 10)
-access keys and terraform state saved/located locally
The risk I know based on my limited knowledge is regarding the accesskeys and key pair. Since its located locally then its less than ideal specially if we intend to share this in a group. 

Ideally we can use something like azure keyvault to store those senstive credentials. Or if using Azure devops use the variable groups in the pipeline which has the option to encrypt some variables. 

Same goes for the terraform states, it would be good if the backend is on the clound as well where it can be shared with the team more safely, coz if its store locally and my computer gets destroyed. Might cause a problem.



Bonus Task and Task 8b: 
Unfortunately, I don't have enough knowledge to implement these 2 sucessfully at the moment, I did some research but not enough time to figure it out completely. 

The lead I had been trying to follow for these 2 task is by using python with readline and displaying the output on HTML Django and/or flask and a reversy proxy setting on nginx. But those involve a couple of topics I haven't used before or in a while. 

So I'll do some self learning on them after busy season when there's free time. 

Getting a python code that does basic search seems simple enough, I have one I saw on one article and tested (file name wordSearch.py), but I haven't gotten to converting it to a Rest API yet.

