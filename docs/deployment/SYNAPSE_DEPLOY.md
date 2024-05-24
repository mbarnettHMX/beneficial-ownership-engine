## Pre-requirements

We will need:

- [Windows Store Ubuntu 22.04 LTS](https://apps.microsoft.com/store/detail/ubuntu-22042-lts/9PN20MSR04DW)
- [Visual Studio Code](https://visualstudio.microsoft.com/downloads/)


---
## Connect to Ubuntu WSL with VSCode

>1. Launch VSCode.
>2. Select **View > Terminal**. A new window should open along the bottom of the VSCode window.
>3. From this windows use the **Launch Profile** dropdown to open the **Ubuntu 22.04 (WSL)** terminal. ![image](images%2Fvscode_terminal_windows.png)
>4. A bash prompt should open in the format `{username}@{machine_name}:/mnt/c/Users/{username}$`
---

## Install Azure CLI and terraform On WSL

In your Ubuntu 22.04(WSL) terminal from the previous step, follow the directions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux) to install Azure CLI.

Also install terraform using the instructions [here](https://developer.hashicorp.com/terraform/install#linux)


---

## Login to Azure in wsl environment 

In your Ubuntu 22.04(WSL) terminal from the Connect to Ubuntu WSL with VSCode step, run the following commands 


``` bash
    az login
    az account set --subscription mysubscriptionID
```

## Set terraform variables as needed in the file 

There is a file named terraform.tfvars which has the following values. Change the values based on your specific requirements

Variable | Description
--- |  ---
resource_group_name |  The Name of the resource group in which the resoruces are deployed 
location_for_resoruces | Your resources wil be deployed in the location specified here 
storage_account_name | Please give name of the storage account to be created.
synapse_name | Please give name of the synapse to be created
spark_name | Please provide the name of the spark pool to be created 



Then run the following commands

``` bash
    terraform init
    terraform apply --auto-approve
```

Once this is done you will see a success message that your resources are deployed.