# Synapse Deployment Instructions

Follow the steps below to deploy Azure Synapse and supporting storage account and Spark cluster for the Beneficial Ownership Engine.

## Prerequisites

We will need:

- [Windows Store Ubuntu 22.04 LTS](https://apps.microsoft.com/store/detail/ubuntu-22042-lts/9PN20MSR04DW)
- [Visual Studio Code](https://visualstudio.microsoft.com/downloads/)
- [Python 3.8](https://www.python.org/downloads/release/python-380/) (Will need to upgrade to [Python 3.10](https://apps.microsoft.com/detail/9pjpw5ldxlz5?hl=en-us&gl=US) to use Azure Spark 3.3)

---

## Install pip and poetry

The pip package manager is required to install the Poetry tool. To install pip in PowerShell, follow these steps:

1. Download the get-pip.py script from the [this website](https://bootstrap.pypa.io/get-pip.py).
2. Open PowerShell with Administrative access.
3. Navigate to the location of the downloaded get-pip.py file using the 'cd' command.
4. Install pip by running the following command:

``` powershell
py get-pip.py
```

If you want to upgrade your existing pip installation, you can do so by running the following command:

``` powershell
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

``` powershell
poetry --version
```

If Poetry has been successfully installed, you should see its version number printed in the terminal.

## Generate wheel file

After installing python 3.8, pip, and Poetry, in Power Shell navigate to the folder containing Beneficial Ownership Engine code (the top level, e.g. "C:\Users\SmartCloudAI\Documents\GitHub\ACTS-Beneficial-Ownership-Engine") and type `code .` to start Visual Studio Code from that folder. Next, run the following commands from a Power Shell terminal in your VS Code.

``` powershell
    cd .\python\transparency-engine\
    poetry build
```

You should see the following in output in PowerShell:

``` powershell
    Building transparency-engine (0.1.0)
      - Building sdist
      - Built transparency_engine-0.1.0.tar.gz
      - Building wheel
      - Built transparency_engine-0.1.0-py3-none-any.whl
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

## Login to Azure in the WSL Environment

In the Ubuntu 22.04(WSL) terminal opened in the 'Connect to Ubuntu WSL with VS Code' step, run the following commands:

``` bash
    az login
    az account set --subscription mysubscriptionID
```

## Set Terraform variables

In the file named terraform.tfvars in the 'synapse_deploy' folder, change the values of the following variables:

Variable | Description
--- |  ---
resource_group_name |  The Name of the resource group into which the resources are deployed.
location_for_resources | The location where the resources will be deployed.

Next, run the following commands:

``` bash
    terraform -chdir=synapse_deploy init
    terraform -chdir=synapse_deploy apply --auto-approve
```

Once these commands complete you will see a success message indicating that the resources are deployed. If you encounter errors while deploying, the Terraform commands above can be re-applied, and this may resolve the errors encountered.

## Install the Required Beneficial Ownership Packages

The Spark Pool deployed for the Beneficial Ownership Engine references Python module 'transparency_engine'. The deployment of Azure services created the required 'transparency_engine-0.1.0-py3-none-any.whl' file containing the required modules, and these must be added to the Packages configuration of the Spark Pool following these steps:

>1. In Synapse Studio, select the 'Manage; icon in the left-hand panel, then select 'Apache Spark pools' item in the list. This will display the available Spark pools.
>2. Mouse over the row with the name of your Spark pool and right-click the '...' and select 'Packages'. This will display the Packages dialog on the right.
>3. Under 'Workspace packages' click the + and from the 'Select from workspace packages', select the 'transparency_engine-0.1.0-py3-none-any.whl' file, then select Apply.

The change in configuration batch job may take several minutes, and you can monitor the progress of the batch job by selecting the Monitor icon on the left-hand side of Synapse Studio, then selecting 'Apache Spark applications'. Refresh the list to confirm that the 'Status' is 'Completed'.

## Run the Notebook

If the above depoyment and configuration is complete, you can run the Beneficial Ownership Engine following these steps:

>1. In Synapse Studio, navigate to the Notebooks by clicking on the 'Develop' icon on the left-hand side, the select the Beneficial_Ownership_Engine notebook. This will display the notebook on in Synapse Studio.
>2. Edit the code panel labelled "Manually Update SubFolderpath for this Run" including the 'subfolderpath', 'datecountry' and 'storagename'. These correspond, respectively, to the subfolder in the 'curated' container of the Storage Account created in the Beneficial Ownership Engine deployment, a name that will be used as a folder name for the results, and the name of the Storage Account created in the Beneficial Ownership Engine deployment.
>3. Upload the seven required input data files. Refer to [Input Data Requirements](./BeneficialOwnershipEngine-InputDataDescriptions.pptx) for information on how to prepare these input data files, or use the synthetic test data files input files provided in the `transparency-engine\samples\input_data` folder.
>4. In the second panel under the Pipeline Configurations section of the Notebook, check file names (do not change the paths) of the input data files selected in the previous step.
>5. Publish the changed you by clicking 'Publish all' at the top of the Notebook, then select 'Run all'

It may take several minutes for the Spark pools to be initialized and, as with any Python Notebook, you can check progress of execution and see any errors by scrolling down through the Notebook.

The complete list of 32 folders (containing parquet file(s)) generated by the Beneficial Ownership Engine upon successful completion of code in the notebook are as follows:

```
06/18/2024  01:17 PM    <DIR>          activity
06/18/2024  10:58 PM    <DIR>          activity_filtered_graph
06/18/2024  10:58 PM    <DIR>          activity_filtered_links
06/18/2024  10:45 PM    <DIR>          activity_links
06/18/2024  01:21 PM    <DIR>          activity_prep
06/18/2024  01:48 PM    <DIR>          attributeDefinition
06/18/2024  01:48 PM    <DIR>          attributeDefinition_prep
06/18/2024  01:21 PM    <DIR>          contact
06/18/2024  01:35 PM    <DIR>          contact_fuzzy_match
06/18/2024  01:54 PM    <DIR>          contact_links
06/18/2024  01:43 PM    <DIR>          contact_prep
06/18/2024  01:46 PM    <DIR>          entity
06/18/2024  01:46 PM    <DIR>          entityReviewFlag
06/18/2024  01:46 PM    <DIR>          entityReviewFlag_metadata
06/18/2024  01:48 PM    <DIR>          entityReviewFlag_prep
06/20/2024  08:45 PM    <DIR>          entity_activity_link_report
06/20/2024  08:32 PM    <DIR>          entity_activity_report
06/20/2024  08:45 PM    <DIR>          entity_attributes_report
06/20/2024  08:46 PM    <DIR>          entity_graph_report
06/18/2024  01:46 PM    <DIR>          entity_prep
06/20/2024  08:45 PM    <DIR>          entity_related_activity_overall_report
06/20/2024  08:40 PM    <DIR>          entity_related_activity_report
06/20/2024  06:41 PM    <DIR>          entity_scoring
06/20/2024  08:34 PM    <DIR>          entity_temporal_activity_report
06/20/2024  08:52 PM    <DIR>          html_report
06/20/2024  06:39 PM    <DIR>          macro_filtered_links
06/18/2024  11:04 PM    <DIR>          macro_links
06/20/2024  06:44 PM    <DIR>          network_scoring
06/18/2024  01:43 PM    <DIR>          ownership
06/18/2024  02:00 PM    <DIR>          ownership_links
06/18/2024  01:46 PM    <DIR>          ownership_prep
06/20/2024  08:52 PM    <DIR>          report_url
```

Of these generated files, 10 are required by the Power BI files provided in the '\powerbi\' folder:

- entity_activity_report
- entity_attributes_report
- entity_graph_report
- entityReviewFlag
- entityreviewflag_metadata
- network_scoring
- entity_temporal_activity_report
- entity_related_activity_report
- entity_related_activity_overall_report
- report_url

## Install the Azure Kubernetes Web App

The Beneficial Ownership Engine uses an API to a Kubernetes web application for generation of HTML reports accessible from the Power BI template, Entity Ranking report. Follow the instructions in the [AKS Deployment Instructions](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/docs/deployment/AKS_DEPLOY.md) to deploy the required web application.

This completes the Synapse deployment required for the Beneficial Ownership Engine.
