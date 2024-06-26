# Local Deployment Instructions

NOTE: These instructions currently are under review and subject to change.

This tutorial describes how to set up the development environment for the Beneficial Ownership Engine components locally using Docker.

## Pre-requisites

1. [Docker](https://docs.docker.com/engine/install/)
2. [Visual Studio Code](https://code.visualstudio.com/)
3. [Visual Studio Code Remote Development Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
4. [GIT] (https://git-scm.com/downloads)

You can follow the instructions [here](https://code.visualstudio.com/docs/devcontainers/containers) for developing inside a Docker container.

## Running the Beneficial Ownership Engine in a Local Deployment

To run the Beneficial Ownership Engine processing pipeline locally, ensure that you have Docker installed and running on your machine. You can find instructions for installing Docker [here](https://docs.docker.com/engine/install/).

### Cloning the Repository and Starting Visual Studio Code

Once the prerequsite software is installed clone using GIT and a command prompt. Choose a new, local folder for the repository, navigate to the new folder, and clone the repository. You can obtain the required repository URL from the 'Code' (green button) on the GitHub Beneficial Ownership landing page:

```Power Shell
git clone <repository URL>
```
Where `<repository URL>` must be replaced with the URL that you copied above.

Next, you can start Visual Studio Code from Power Shell with the following commands and note that you must first navigate to the /python/transparency-engine folder before invoking Visual Studio Code with the `code` command. The following commands assume you are starting from the local folder loaction into which you cloned the repository, for example `C:\Users\myUserID\source\repos\BeneficialOwnership'.

```Power Shell
cd beneficial-ownership-engine\python\transparency-engine
code .
```
THe `code` command will start Visual Studio Code. When Visual Studio Code opens, click on the Explorer icon on the navigation pane at left, select the 'transparency_engine' folder then select 'Terminal->New Terminal' to open a Power Shell in that folder.

### Configuring and Triggering the Pipeline

To configure the pipeline, edit the following two json files, located in the TRANSPARENCY-ENGINE 'samples\config' folder. These can be edited in Visual Studio Code:

- pipeline.json: Specify steps to be executed in the pipeline; however, initially this file should not be changed. The file is provided to allow runniing of some subset of the steps to selectively complete certain steps, or rerun steps.
- steps.json: Specify configurations for each step of the pipeline. This file does not require changes if you want to accept the default configuration settings, and you are using as input the synthetic data provided in the folder samples\inut_data. If you want to modify the default settings or have changed the names or locations of the input data files, then this file must be modified accordingly.

To build and run the Docker container from Power Shell, execute the following commands in sequence from the the python\transparency-engine folder and note the `.` at the end of the `docker build` command tells Docker to use the current directory as the build context:

```Power Shell
docker build -t transparency-engine -f Dockerfile .
```

Run the Docker container just created, using the -v option to  

```Power Shell
docker run -v <path>:/workdir -it beneficial-ownership-engine
```

Where `<path>` must be replaced with the path to the `python/transparency-engine` folder. For clarity and to ensure the path syntax is correct, an example path is `/c/Users/myUserID/source/repos/BeneficialOwnershipEngine/beneficial-ownership-engine/python/transparency-engine`.

The `docker run` command will start the container in Docker interactive mode, indicated by the `root` prompt, for example `root@3a8d6318a1e6:/workdir#`.

To run the pipeline, once in Docker interactive mode, execute the following command from the `/workdir` folder:

```bash
poetry run python transparency_engine/main.py --config samples/config/pipeline.json --steps samples/config/steps.json
```

## Power BI Template, Web Server & API for Report Generation

Once Beneficial Ownership Engine results have been generated following the steps above, you can visualize the results with a Power BI template provided for this purpose. [Power BI Desktop](https://www.microsoft.com/en-in/download/details.aspx?id=58494) is required to load the template. 

Follow these steps to view the Beneficial Ownership Engine results:

1. Download the [local version of the Power BI template](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/powerbi/BeneficialOwnershipEngine.pbit) and double-click the file to open in Power BI Desktop.
2. In the 'BeneficialOwnershipEngine-local' dialog enter the Path to the folder containing the Beneficial Ownership Engine results, ensuring that the final `\` is included in the path, then click OK. By default, Beneficial Ownership Engine results are writting to the local `...\python\transparency-engine\output\` folder, so a typical Path would be `C:\Users\<yourUserName>\source\repos\BeneficialOwnershipEngine\beneficial-ownership-engine\python\transparency-engine\output\demo\`, where `<yourUserName>` must be replaced with the local machine login id.
3. When the data loading is complete, start by viewing the Entity Ranking tab.

### Web Server and API Installation

To install the dependencies needed for the web server and API, execute the following commands from the `python/api-backend` folder:

```bash
pip install poetry
poetry install
```

To run the backend web server and API execute from the root of the project:

```bash
docker-compose up backend_api --build
```

To run the UI, you can either use `docker-compose` or install node and yarn and execute the following commands from the root of the project:

```bash
yarn
yarn build
yarn start # run the webapp locally
```

The web server can now be accessed at http://localhost:3000
