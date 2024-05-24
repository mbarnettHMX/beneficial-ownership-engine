## Pre-requirements

We will need:

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/),
- [Windows Store Ubuntu 22.04 LTS](https://apps.microsoft.com/store/detail/ubuntu-22042-lts/9PN20MSR04DW)
- [Visual Studio Code](https://visualstudio.microsoft.com/downloads/)
- [Terraform] (https://developer.hashicorp.com/terraform/install#linux)


---
## Connect to Ubuntu WSL with VSCode

>1. Launch VSCode.
>2. Select **View > Terminal**. A new window should open along the bottom of the VSCode window.
>3. From this windows use the **Launch Profile** dropdown to open the **Ubuntu 22.04 (WSL)** terminal.
>4. A bash prompt should open in the format `{username}@{machine_name}:/mnt/c/Users/{username}$`
---
### Configure Git in Ubuntu WSL environment


The next step is to configure Git for your Ubuntu WSL environment. We will use the bash prompt from the previous step to issue the following commands:

Set Git User Name and Email

``` bash
    git config --global user.name "Your Name"
    git config --global user.email "youremail@yourdomain.com"
```

``` bash
    git clone repositoryURL
```
---

## Install Azure CLI and terraform On WSL

In your Ubuntu 22.04(WSL) terminal from the previous step, follow the directions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux) to install Azure CLI.

Also install terraform using the instructions [here](https://developer.hashicorp.com/terraform/install#linux)


---

## Login to Azure in wsl environment 

In your Ubuntu 22.04(WSL) terminal from the previous step, run the following commands 


``` bash
    az account show
    az account set --subscription mysubscriptionID
```

## Set terraform variables as needed in the file 

There is a file named terraform.tfvars which has the following values. Change the values based on your specific requirements

resource_group_name = "your-resourceg-roupname"   
location_for_resoruces = "location"  
storage_account_name = "storageaccountname"  
synapse_name = "synapse-name "
spark_pool_name = "apachesparkname"

Then run the following commands

``` bash
    terraform init
    terraform plan --auto-approve
```

Once this is done you will see a success message that your resources are deployed.