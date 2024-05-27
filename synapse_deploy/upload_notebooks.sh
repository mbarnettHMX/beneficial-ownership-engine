#!/bin/bash

WORKSPACE_NAME=$1
RESOURCE_GROUP=$2
FOLDER_PATH=$3
SPARK_NAME=$4

# Checking if variables are available in input
if [ -z "$WORKSPACE_NAME" ] || [ -z "$RESOURCE_GROUP" ] || [ -z "$FOLDER_PATH" ] || [ -z "$SPARK_NAME" ]; then
    echo "Usage: $0 <workspace_name> <resource_group> <folder_path> <spark_name>"
    exit 1
fi

az synapse notebook import --workspace-name "$WORKSPACE_NAME" --name NB_GenerateData --file @"./synapse_notebooks/NB_GenerateData.ipynb"
az synapse notebook import --workspace-name "$WORKSPACE_NAME" --name NB_Run_Transparency_Engine_DR --file @"./synapse_notebooks/NB_Run_Transparency_Engine_DR.ipynb"
az synapse notebook import --workspace-name "$WORKSPACE_NAME" --name NB_Run_Transparency_Engine_Params --file @"./synapse_notebooks/NB_Run_Transparency_Engine_Params.ipynb"
az synapse notebook import --workspace-name "$WORKSPACE_NAME" --name NB_Run_Transparency_Engine --file @"./synapse_notebooks/NB_Run_Transparency_Engine.ipynb"
cp -r ../python/transparency-engine/dist/transparency_engine-0.1.0-py3-none-any.whl .
az synapse workspace-package upload --workspace-name "$WORKSPACE_NAME" --package "transparency_engine-0.1.0-py3-none-any.whl"
sleep 120
az synapse spark pool update --name "$SPARK_NAME" --workspace-name "$WORKSPACE_NAME" --resource-group "$RESOURCE_GROUP" --package-action Add --package transparency_engine-0.1.0-py3-none-any.whl
echo "Notebooks uploaded successfully."
