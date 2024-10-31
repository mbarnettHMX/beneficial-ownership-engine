# Beneficial Ownership Engine

Beneficial Ownership Engine detects and visualizes explicit and implicit connections between entities and activities to support situational awareness and targeted action. Applications include identifying risks due to adversarial activities (e.g., corruption and collusion) hidden within large datasets of corporate and government entity metadata and activity records.

Given a collection of streaming data sources describing the attributes and actions of real-world entities, the Beneficial Ownership Engine uses a range of network machine learning techniques including graph modeling, joint graph embedding [[1-3]](#references), and other statistical techniques to detect and explain the networks of entities including features (common activities over time, historical connections, similar contact information, etc.) that closely relate the entities.

To prioritize the expert review of the discovered entity networks, entities can be linked to "risk signals" that indicate the need for inspection. Risk signals may be signs of either opportunities ("green flags") or risks ("red flags") that arise from the relationships between entities. The more risk signals in an entity's network, the higher the risk and the priority for review of that entity's network.

For each entity in the dataset, the Beneficial Ownership Engine generates a report illustrating the detected relationships and risk signals contributing to its overall risk. In typical use, these reports inform real-world actions targeted at either the entity or its broader network.

The Beneficial Ownership Engine comprises three components:

1. Processing Pipeline: A Python package that manages processing of the seven (7) required input files using graph modeling techniques to detect networks of closely-related entities.
2. Web Server & API: A web server and API for querying the results produced by the Beneficial Ownership Processing pipeline.
3. Power BI and HTML Reports: A [Beneficial Ownership Power BI template](https://github.com/mbarnettHMX/beneficial-ownership-engine/tree/main/powerbi) for reviewing Beneficial Ownership Engine results, and a React-based web server to enable generation of entity narrative reports that can also be exported to PDF file format.

## Getting Started

There are two deployment options for the Beneficial Ownership Engine:

1. Azure Synapse deployment, and
2. Local deployment.

Efficient processing is important for the Beneficial Ownership Engine, which is compute-intensive especially for large datasets. Thus, the Azure Synapse deployment option is recommended.

For Azure Synapse deployment refer to the [Synapse Deployment Instructions](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/docs/deployment/SYNAPSE_DEPLOY.md) document.

For local deployment on a laptop, desktop, or virtual machine, follow the instructions in [Local Deployment Instructions](https://github.com/mbarnettHMX/beneficial-ownership-engine/blob/main/docs/deployment/LOCAL_DEPLOY.md).

## References

1. Alexander Modell, Ian Gallagher, Joshua Cape, and Patrick Rubin-Delanchy. "Spectral embedding and the latent geometry of multipartite networks." arXiv preprint arXiv:2202.03945 (2022).

2. Nick Whiteley, Annie Gray, and Patrick Rubin-Delanchy. "Matrix factorisation and the interpretation of geodesic distance." Advances in Neural Information Processing Systems 34 (2021): 24-38.

3. Ian Gallagher, Andrew Jones, and Patrick Rubin-Delanchy. "Spectral embedding for dynamic networks with stability guarantees." Advances in Neural Information Processing Systems 34 (2021): 10158-10170.

## Contributing

[HMX Corporation](https://hmx.ai) has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [ai@hmx.ai](mailto:ai@hmx.ai) with any questions or comments.
