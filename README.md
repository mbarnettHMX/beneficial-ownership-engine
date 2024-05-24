# Beneficial Ownership Engine

Beneficial Ownership Engine aims to detect and communicate the implicit structure of complex activities in real-world problem areas, in ways that support both situational awareness and targeted action. A potential application is to identify and counter adversarial activities (e.g., corruption) hidden within large-scale datasets.

Given a collection of streaming data sources describing the attributes and actions of real-world entities, it uses a range of graph modeling, joint graph embedding [[1-3]](#references), and other statistical techniques to detect and explain the networks of entities most closely related to each entity. 

To prioritize the expert review of these entity networks, entities can be linked to "review flags" that indicate the need for inspection. Review flags may be signs of either opportunities ("green flags") or risks ("red flags") thought to transfer between closely-related entities. The more review flags in an entity network, the higher the priority of that network for review.

For each entity in the dataset, Transparency Engine generates a narrative report illustrating the detected relationships and review flags contributing to its overall review priority. In typical use, review of high-priority reports will help inform real-world actions targeted at either the entity or its broader network. 

Beneficial Ownership Engine consists of three components:

1. Processing Pipeline: Python package that manages processing of the seven (7) required input files using graph modeling techniques to detect networks of closely-related entities.
2. API: A FastAPI interface for querying the entity report produced by the Beneficial Ownership Processing pipeline.
3. Report: A React-based application that enables viewing of the entity narrative report and exporting the report to a PDF file. The [Beneficial Ownership Power BI template](https://github.com/mbarnettHMX/beneficial-ownership-engine/powerbi/TransparencyEngine.pbit) provides access to these reorts.


## Getting Started

There are two deployment options for the Beneficial Ownership Engine:

1. Azure Synapse deployment, and
2. Local deployment.
Processing requirements are important for the Beneficial Ownership Engine, especially for large datasets, thus the Azure Synapse deployment is  reccommended.

For Azure Synapse deployment refer to the [Synapse Deployment Instructions]([https://github.com/mbarnettHMX/beneficial-ownership-engine/docs/deployment/SYNAPSE_DEPLOY.md](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/docs/deployment/SYNAPSE_DEPLOY.md)) document.

For local deployment on a laptop, desktop, or virtual machine, follow the instructions in [Local Deployment Instructions]([https://github.com/mbarnettHMX/beneficial-ownership-engine/docs/deployment/LOCAL_DEPLOY.md](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/docs/deployment/LOCAL_DEPLOY.md)).

## Web Application to Support Reporting Capabilities

### API

To install the dependencies needed for the API, execute the following commands from the `python/api-backend` folder:

```bash
pip install poetry
poetry install
```

To run the backend API execute from the root of the project:

```bash
docker-compose up backend_api --build
```

### Report

To run the UI, you can either use `docker-compose` or install node and yarn and execute the following commands from the root of the project:

```bash
yarn
yarn build
yarn start # run the webapp locally
```

The webapp will be available at http://localhost:3000

## References

1. Alexander Modell, Ian Gallagher, Joshua Cape, and Patrick Rubin-Delanchy. "Spectral embedding and the latent geometry of multipartite networks." arXiv preprint arXiv:2202.03945 (2022).

2. Nick Whiteley, Annie Gray, and Patrick Rubin-Delanchy. "Matrix factorisation and the interpretation of geodesic distance." Advances in Neural Information Processing Systems 34 (2021): 24-38.

3. Ian Gallagher, Andrew Jones, and Patrick Rubin-Delanchy. "Spectral embedding for dynamic networks with stability guarantees." Advances in Neural Information Processing Systems 34 (2021): 10158-10170.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
