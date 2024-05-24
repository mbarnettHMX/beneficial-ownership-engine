# Synapse Deployment Instructions

Follow the steps below to deploy Azure Synapse and supporing storage account and Spark cluster for the Beneficial Ownership Engine.

## Prerequisites

We will need:

- [Windows Store Ubuntu 22.04 LTS](https://apps.microsoft.com/store/detail/ubuntu-22042-lts/9PN20MSR04DW)
- [Visual Studio Code](https://visualstudio.microsoft.com/downloads/)

---

## Connect to Ubuntu WSL with VSCode

>1. Launch VSCode.
>2. Select **View > Terminal**. A new window should open along the bottom of the VSCode window.
>3. From this windows use the **Launch Profile** dropdown to open the **Ubuntu 22.04 (WSL)** terminal. ![image](images%2Fvscode_terminal_windows.png)
>4. A bash prompt should open in the format `{username}@{machine_name}:/mnt/c/Users/{username}$`
>
---

## Install Azure CLI and Terraform On WSL

In your Ubuntu 22.04(WSL) terminal from the previous step, follow the directions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux) to install Azure CLI.

Netxt, install Terraform using the instructions [here](https://developer.hashicorp.com/terraform/install#linux)

---

## Login to Azure in the WSL environment

In the Ubuntu 22.04(WSL) terminal opened in the 'Connect to Ubuntu WSL with VSCode' step, run the following commands:

``` bash
    az login
    az account set --subscription mysubscriptionID
```

## Set Terraform variables as needed in the file

There is a file named terraform.tfvars in synapse_deploy folder which has the following values. Change the values of the varibales in the file

Variable | Description
--- |  ---
resource_group_name |  The Name of the resource group into which the resoruces are deployed.
location_for_resoruces | Your resources wil be deployed in the location specified here.
storage_account_name | The name of the storage account to be created.
synapse_name | The name of the Synapse to be created.
spark_name | The name of the Spark pool to be created.

Next, run the following commands

``` bash
    terraform -chdir=synapse_deploy init
    terraform -chdir=synapse_deploy apply --auto-approve
```

Once these commands complete you will see a success message indicating that your resources are deployed. This completes the Synapse deployment required for the Beneficial Ownership Engine.
