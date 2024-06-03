build# Synapse Deployment Instructions

Follow the steps below to deploy Azure Synapse and supporting storage account and Spark cluster for the Beneficial Ownership Engine.

## Prerequisites

We will need:

- [Windows Store Ubuntu 22.04 LTS](https://apps.microsoft.com/store/detail/ubuntu-22042-lts/9PN20MSR04DW)
- [Visual Studio Code](https://visualstudio.microsoft.com/downloads/)
- [Python 3.8](https://www.python.org/downloads/release/python-380/)

---
## Install pip and poetry

The pip package manager is requred to install the Poetry tool. To install pip in PowerShell, follow these steps:

1. Download the get-pip.py script from the [official pip website](https://bootstrap.pypa.io/get-pip.py).
2. Open PowerShell with Administrative access.
3. Navigate to the location of the downloaded get-pip.py file using the 'cd' command.
4. Install pip by running the following command:

``` PowerShell
py get-pip.py
```

If you want to upgrade your existing pip installation, you can do so by running the following command:

``` PowerShell
python -m pip install --upgrade pip
```

The Poetry package, a tool for dependency management and packaging in Python, is required to build the wheel file. These installation instructions have been tested with PowerShell. For alternative installations, please see instructions at [the Poetry website](https://python-poetry.org/docs/). 

1. Open PowerShell with Administrative access.
2. In the PowerShell window, paste the following command and press Enter:
``` PowerShell
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -
``` 
3. Once the installation is complete, it will provide you with a path. Copy this path as you’ll need to add it to your user environment variables.
4. Right-click on the Start button and select “System”. In the System window, click on “Advanced system settings” on the left sidebar. In the System Properties window, click on the “Environment Variables…” button. In the Environment Variables window, under “User variables for [YourUsername]”, find the “PATH” variable and select it. Click on the “Edit…” button. In the Edit Environment Variable window, click on “New” and paste the path you copied from the installation process. Click “OK” on all open windows to save your changes.
5. Close the PowerShell window and open a new PowerShell. This is necessary for PowerShell to recognize the change in PATH.
6. In the new PowerShell window, type the following an press Enter:
``` PowerShell
poetry --version
``` 
If Poetry has been successfully installed, you should see its version number printed in the termina.

## Generate wheel file

After installing python 3.8, pip, and Poetry, run the following commands from the PowerShell terminal in your VS Code.

``` PowerShell
    cd .\python\transparency-engine\
    poetry build
```

## Connect to Ubuntu WSL with VS Code

>1. Launch VS Code.
>2. Select **View > Terminal**. A new terminal window should open along the bottom of the VS Code window.
>3. In this terminal window use the **Launch Profile** dropdown to open the **Ubuntu 22.04 (WSL)** terminal. ![image](images%2Fvscode_terminal_windows.png)
>4. A bash prompt should open in the format `{username}@{machine_name}:/mnt/c/Users/{username}$`
>
---

## Install Azure CLI and Terraform On WSL

In your Ubuntu 22.04(WSL) terminal from the previous step, follow the directions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux) to install Azure CLI.

Next, install Terraform using the instructions [here](https://developer.hashicorp.com/terraform/install#linux)

---

## Login to Azure in the WSL environment

In the Ubuntu 22.04(WSL) terminal opened in the 'Connect to Ubuntu WSL with VS Code' step, run the following commands:

``` bash
    az login
    az account set --subscription mysubscriptionID
```

## Set Terraform variables as needed in the file

In the file named terraform.tfvars in the synapse_deploy folder, change the values of the following variables:

Variable | Description
--- |  ---
resource_group_name |  The Name of the resource group into which the resources are deployed.
location_for_resoruces | The location where the resources will be deployed.

Next, run the following commands:

``` bash
    terraform -chdir=synapse_deploy init
    terraform -chdir=synapse_deploy apply --auto-approve
```

Once these commands complete you will see a success message indicating that the resources are deployed. This completes the Synapse deployment required for the Beneficial Ownership Engine.

If you encounter errors while deploying, the Terraform commands above can be re-applied, and this may resolve the errors encountered.
