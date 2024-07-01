# Local Deployment Instructions

This tutorial describes how to set up the development environment for the Beneficial Ownership Engine components locally using Docker.

## Prerequisites

1. [Docker](https://docs.docker.com/engine/install/)
2. [Visual Studio Code](https://code.visualstudio.com/)
3. [Visual Studio Code Remote Development Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
4. [GIT](<https://git-scm.com/downloads>)

You can follow the instructions [here](https://code.visualstudio.com/docs/devcontainers/containers) for developing inside a Docker container.

## Running the Beneficial Ownership Engine in a Local Deployment

To run the Beneficial Ownership Engine processing pipeline locally, ensure that you have Docker installed and running on your machine. You can find instructions for installing Docker [here](https://docs.docker.com/engine/install/).

### Cloning the Repository and Starting Visual Studio Code

Once the prerequisite software is installed clone using GIT and a command prompt. Choose a new, local folder for the repository, navigate to the new folder, and clone the repository. You can obtain the required repository URL from the 'Code' (green button) on the GitHub Beneficial Ownership landing page:

```Power Shell
git clone <repository URL>
```

Where `<repository URL>` must be replaced with the URL that you copied above.

Next, you can start Visual Studio Code from Power Shell with the following commands and note that you must first navigate to the /python/transparency-engine folder before invoking Visual Studio Code with the `code` command. The following commands assume you are starting from the local folder location into which you cloned the repository, for example `C:\Users\myUserID\source\repos\BeneficialOwnership'.

```Power Shell
cd beneficial-ownership-engine\python\transparency-engine
code .
```

THe `code` command will start Visual Studio Code. When Visual Studio Code opens, click on the Explorer icon on the navigation pane at left, select the 'transparency_engine' folder then select 'Terminal->New Terminal' to open a Power Shell in that folder.

### Configuring and Triggering the Pipeline

To configure the pipeline, edit the following two json files, located in the TRANSPARENCY-ENGINE 'samples\config' folder. These can be edited in Visual Studio Code:

- pipeline.json: Specify steps to be executed in the pipeline; however, initially this file should not be changed. The file is provided to allow running of some subset of the steps to selectively complete certain steps, or rerun steps.
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

1. Download the [local version of the Power BI template](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/powerbi/BeneficialOwnershipEngine-local.pbit) and double-click the file to open in Power BI Desktop.
2. In the 'BeneficialOwnershipEngine-local' dialog enter the Path to the folder containing the Beneficial Ownership Engine results, ensuring that the final `\` is included in the path, then click 'OK'. By default, Beneficial Ownership Engine results are written to the local `...\python\transparency-engine\output\` folder, so a typical Path would be `C:\Users\<yourUserName>\source\repos\BeneficialOwnershipEngine\beneficial-ownership-engine\python\transparency-engine\output\demo\`, where `<yourUserName>` must be replaced with the local machine login id.
3. When the data loading is complete, start by viewing the Entity Ranking tab.

### Web Server and API Installation

The Power BI report includes a 'report_url_local' table containing HTML reports for each EntityID in the Beneficial Ownership Engine analysis. The 'ReportLink' column of this table can be added to the 'Entity Scores' table as a column. Use the 'Format visuals -> Cell elements' with 'Web URL' On to display the URLs as links, then follow the instructions below to deploy a local web application and API to support display of the HTML reports in a browser.

To install the dependencies needed for the web server and API, execute the following commands from the `python\api-backend` folder:

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

The web server can now be accessed at <http://localhost:3000>

## Notes on Running the Beneficial Ownership Engine Locally

The Beneficial Ownership Engine requires compute resources that can exceed the available processing capacity and local memory on some machines. For reference, the machine used for testing hte local deployment was configured with an Intel(R) Xeon(R) CPU E3-1505M v5 @ 2.80GHz-2.81GHz processor with 64GBytes of installed RAM.

Two changes were made to the Spark configuration in the '\python\transparency-engine\transparency-engine\Dockerfile' before deployment and these changes have been made to this repository.

```
ENV SPARK_EXECUTOR_MEMORY=4g
ENV SPARK_DRIVER_MEMORY=16g
```

These commands are used to set environment variables in Apache Spark deployment, specifically for configuring the memory usage:

- ENV SPARK_EXECUTOR_MEMORY=4g: This command sets the amount of memory to be used by each executor process, i.e., each running task. Here, it’s set to 4 gigabytes. The executor memory is the memory that Spark uses to run data processing tasks.
- ENV SPARK_DRIVER_MEMORY=16g: This command sets the amount of memory to be used by the driver program, which is the program that declares the transformations and actions on data and submits such requests to the system. Here, it’s set to 16 gigabytes. The driver memory is the memory that Spark uses to run the driver program’s operations.

These settings are an important determinant of performance. If not enough memory is allocated, the Beneficial Ownership Engine may fail with OutOfMemory errors. Conversely, if too much memory is allocated, resources that could be used by other applications may be wasted. Therefore, it’s important to tune these parameters according to the needs of your specific analysis use case.

In addition to the Spark configurations above, two additional changes are made to the '\python\transparency-engine\transparency-engine\spark\utils.py' file to address port availability and timeout issues:

```
# Initialize SparkSession and SparkContext
config = SparkConf().setAll([("spark.executor.allowSparkContext", "true"), ("spark.port.maxRetries", "200"),("spark.ui.port", "14058"),("spark.sql.broadcastTimeout", "3600")]) 
```

Finally, experience with the Beneficial Ownership Engine both locally and in Azure deployments has shown that when OutOfMemory errors occur at a specific step in the processing steps (see [pipeline.json](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/python/transparency-engine/samples/config/pipeline.json))it is possible to remove the previous, successfully-executed, steps in the pipeline from [steps.json](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/python/transparency-engine/samples/config/steps.json) and rerunning by executing the `poetry run python transparency_engine/main.py...` command described above. In practice, this results in a completed run and generation of all the required output files in the local 'python\transparency-engine\output\' folder.

The complete list of 32 folders (containing parquet file(s)) generated by the Beneficial Ownership Engine upon successful complete are as follows:

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
