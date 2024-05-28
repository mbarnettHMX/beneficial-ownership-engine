# Local Deployment Instructions

NOTE: These instructions currently are under review and subject to change.

This tutorial describes how to set up the development environment for the Beneficial Ownership Engine components using Docker.

## Pre-requisites

1. [Docker](https://docs.docker.com/engine/install/)
2. [Visual Studio Code](https://code.visualstudio.com/)
3. [Visual Studio Code Remote Development Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

You can follow the instructions [here](https://code.visualstudio.com/docs/devcontainers/containers) for developing inside a Docker container.

## Running the Beneficial Ownership Engine in a Local Deployment

To run the Beneficial Ownership Engine processing pipeline locally, ensure that you have Docker installed and running on your machine. You can find instructions for installing Docker [here](https://docs.docker.com/engine/install/),

### Pipeline

To configure the pipeline, specify the pipeline configuration using two json files:

- Pipeline config: Specify steps to be executed in the pipeline. An example pipeline config can be found in `transparency-engine-main\python\transparency-engine\samples\config\pipeline.json`
- Steps config: Specify configurations for each step of the pipeline. An example steps config can be found in `transparency-engine-main\python\transparency-engine\samples\config\steps.json`

To launch the pipeline's Docker container, execute the following command from the root of the project:

```bash
docker build Dockerfile -t transparency-engine
docker run -it transparency-engine
```

To run the pipeline, once in Docker interactive mode, execute the following command from the `python/transparency-engine` folder:

```bash
poetry run python transparency_engine/main.py --config pipeline.json --steps steps.json
```

The pipeline can also be launched in Visual Studio Code. To do so, open the project in Visual Studio Code and attach the project to a Docker container by following the instructions [here](https://code.visualstudio.com/docs/remote/containers).

The pipeline can also be packaged as a wheel file to be installed on Azure Synapse or Databricks. To create the wheel file, execute the following command from the `python/transparency-engine` folder:

```bash
poetry build
