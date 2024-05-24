#!/bin/bash


WORKSPACE_NAME=$1
RESOURCE_GROUP=$2
FOLDER_PATH=$3

# Checking if variables are available in input
if [ -z "$WORKSPACE_NAME" ] || [ -z "$RESOURCE_GROUP" ] || [ -z "$FOLDER_PATH" ]; then
    echo "Usage: $0 <workspace_name> <resource_group> <folder_path>"
    exit 1
fi

# Loop and upload the files
echo "Uploading notebooks..."
for notebook in $FOLDER_PATH/*.ipynb; do
    NOTEBOOK_NAME=$(basename $notebook .ipynb)
    echo "Importing notebook: $NOTEBOOK_NAME"
    az synapse notebook import --workspace-name $WORKSPACE_NAME --name $NOTEBOOK_NAME --file @${notebook}
done

echo "Notebooks uploaded successfully."
