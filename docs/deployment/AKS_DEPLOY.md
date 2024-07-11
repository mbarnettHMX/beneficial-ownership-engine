# Deploying to AKS

This document describes how to create and configure a Kubernetes cluster on Azure (AKS) and run a Kubernetes Helm chart to deploy the Beneficial Ownership Engine API required for HTML report generation.

## 0. Pre-requirements

The following are required to complete the deployment:

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/),
- [Helm](https://helm.sh/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/) installed locally
- [Docker](https://docs.docker.com/engine/install/)

## 1. Initial setup

### 1.1. Azure CLI login

First, log into Azure and set the subscription:

```bash
> az login
> az account set --subscription {SUBSCRIPTION_NAME}
```

### 1.2. Create resource group

Next, create the resource group that will store the AKS cluster.

```bash
> az group create --name {RESOURCE_GROUP_NAME} --location {LOCATION}
```

## 2. AKS Cluster

### 2.1. AKS Cluster

> In this example the cluster is created with 2 nodes.

```bash
> az aks create -g {RESOURCE_GROUP_NAME} -n {AKS_CLUSTER_NAME} --enable-managed-identity --node-count 2 --enable-addons monitoring --enable-msi-auth-for-monitoring --generate-ssh-keys --location {LOCATION}
```

### 2.2. AKS Cluster's resource group name

Azure will also create another resource group into which the resources related to the AKS cluster will be placed. We can check its name using the following command:

```bash
> az aks show --resource-group {RESOURCE_GROUP_NAME} --name {AKS_CLUSTER_NAME} --query nodeResourceGroup -o tsv
```

The above command will output `MC_{RESOURCE_GROUP_NAME}_{AKS_CLUSTER_NAME}_{LOCATION}`, from which we can obtain `{AKS_RESOURCE_GROUP_NAME}`.

## 3. Ingress controller

The deployment will use an ingress controller to manage access to the services running in the cluster and to load balance incoming requests.

### 3.1. Creating static IP

Create a static IP that will be the entry point for accessing the cluster through the ingress controller:

```bash
> az network public-ip create --resource-group {AKS_RESOURCE_GROUP_NAME} --name {INGRESS_IP_NAME} --dns-name {DNS_NAME} --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv
```

The above command will output the static IP allocated `{INGRESS_STATIC_IP}`.

The fully qualified domain name will be `{DNS_NAME}.{LOCATION}.cloudapp.azure.com`, from which we can obtain the `{DOMAIN}`.

### 3.2. Getting access to the cluster

The cluster is accessed from the machine running Azure CLI. To do this, first get the credentials to the cluster configured in `kubectl`:

```bash
> az aks get-credentials --resource-group {RESOURCE_GROUP_NAME} --name {AKS_CLUSTER_NAME}
```

Then verify if `kubectl` is using the correct context related to the cluster just created:

```bash
> kubectl config get-contexts
```

### 3.3. Install ingress controller

Now that access to the cluster has been provided through `kubectl`, install the NGINX ingress controller using Helm. To do so, create the YAML file (`nginx-ingress.yaml`) with the configuration for the ingress controller:

```yml
controller:
  service:
    loadBalancerIP: { INGRESS_STATIC_IP }
    externalTrafficPolicy: Local
```

> Replace {INGRESS_STATIC_IP} with the IP you got in the previous steps.

Notice `externalTrafficPolicy: Local`, which is important so that the real IPs for the incoming requests are logged in the ingress controller, instead of the local cluster.

Now the NGINX ingress controller can be deployed to the cluster:

```bash
> helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
> helm repo update
> helm install ingress-nginx ingress-nginx/ingress-nginx --create-namespace --namespace ingress-nginx -f helm/aks/nginx-ingress.yaml
```

Successful deployment can be confirmed by running:

```bash
> kubectl get all,ingress -n ingress-nginx
```

You should see the deployed ingress controller configured with the specified external IP.

> Another method is to provide the access tokens to the ACR directly through Kubernetes secrets.

## 4. Container registry

Next, create an Azure Container Registry (ACR) to store the services' images that will run in the Kubernetes cluster.

### 4.1. Create ACR

```bash
> az acr create --resource-group {RESOURCE_GROUP_NAME} --name {ACR_NAME} --sku Standard
```

### 4.2. Attach ACR to AKS

We need to attach the ACR to AKS, so the cluster can read images from the registry. Notice that this requires `Owner` role on the subscription:

```bash
> az aks update -n {AKS_CLUSTER_NAME} -g {RESOURCE_GROUP_NAME} --attach-acr {ACR_NAME}
```

### 4.3. Manual Operation

#### Login to ACR

```bash
> az acr login -n {ACR_NAME}
```

#### Deploy to the acr

`cd javascript/webapp && yarn install && yarn bundle`
`./scripts/build-frontend-images.sh`
`./scripts/build-backend-images.sh {ACR_NAME}.azurecr.io`
`docker tag backend {ACR_NAME}.azurecr.io/backend`
`docker tag frontend {ACR_NAME}.azurecr.io/frontend`
`docker push {ACR_NAME}.azurecr.io/frontend`
`docker push {ACR_NAME}.azurecr.io/backend`

## 5. Authentication

To authenticate requests made to the services in the cluster we use the [OAuth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) service.

### 5.1. App registration on Azure Active Directory

First create an APP registration on Azure Entra ID (previouly Azure Active Directory):

1. Create the new APP registration (Single tenant).
2. In the `Authentication` left menu, add a new Web Platform configuration with:
1. Redirect URL: `https://{DOMAIN}.cloudapp.azure.com/oauth2/callback`.
2. Front-channel logout URL: `https://{DOMAIN}.cloudapp.azure.com/oauth2/sign_out`.
3. In the `Certificates & secrets` left menu, add a new client secret. Make sure to copy the newly created secret value, which will be the `{CLIENT_SECRET}` used below.
4. In the `API permissions` left menu click on `Microsoft.Graph` and select the `email` and `openid` permissions (OpenID permissions). You won't need `User.Read`, so you can remove it.
5. In the `Expose an API` left menu, click on `set` near to `Application ID URI`, use the suggested value and click `Save`.
6. In the `Manifest` left menu, add or update the `accessTokenAcceptedVersion` in the JSON config to `2` (integer, not string - `"accessTokenAcceptedVersion": 2`).

### 5.2. Configure secrets for causal-services Helm Chart

The `causal-services` helm chart is configured to use OAuth2 Proxy to authenticate and authorize requests. For it to properly work we will need to create a few secrets in the Kubernetes cluster. The following file (`oauth-secrets.yaml`) is used:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: oauth-proxy-secret
  namespace: oauth-proxy
stringData:
  oidc-issuer-url: https://login.microsoftonline.com/{TENANT_ID}/v2.0
  scope: openid email
  client-id: { CLIENT_ID }
  client-secret: { CLIENT_SECRET }
  cookie-secret: { RANDOMLY_GENERATED_COOKIE_SECRET }
  cookie-name: { COOKIE_NAME }
```

- Replace `{TENANT_ID}`, `{CLIENT_ID}` and `{CLIENT_SECRET}` with information from the App Registration (available in the `Overview` left menu).

- `{RANDOMLY_GENERATED_COOKIE_SECRET}` can be generated using:

  ```bash
  python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
  ```

- `{COOKIE_NAME}` is the cookie name in the browser that will store the authorization token (e.g. `_auth_token`).

Once the file is configured correclty, create the namespace for the oauth service and apply the secrets to the cluster:

```bash
> kubectl create namespace oauth-proxy
> kubectl apply -f oauth-secrets.yaml
```

## 6. Create chart configuration file

The default configuration for the `causal-services`' chart can be seen at [`values.yaml`](../config/helm/causal-services/values.yaml). We will need to update a few values according to what we have just created and configured. To do so, update the YAML file at location /helm/values.prod.yaml (`values.prod.yaml`) containing the values we need to update (replace the values with `{}` with the proper Aconfiguration):

```yaml
domain: { DOMAIN }
```

Also update values.yaml at location helm/values.yaml with the following values already present in the file.

```yaml
domain: { DOMAIN }

backendImage: {ACR_NAME}.azurecr.io/backend:latest

frontendImage: {ACR_NAME}.azurecr.io/frontend:latest


  #
  # frontend services and ingress
  #
  - namespace: frontend
    services:
      - name: frontend
        image: "{{ .Values.frontendImage }}"
        imagePullPolicy: "{{ .Values.imagesPullPolicy }}"
        replicas: 1
        containerPort: 8080    #update this to 3000
        servicePort: 3005      #update this to 8080
        path: /

```

Update the SQL values shown in the image below. The database name, endpoint, username and password refer to the data lake create by the NB_Run_Transparency_Engine Synapse pipeline. Entries with '_TABLE' refer to default values for folders output by the Beneficial Ownership Engine and do not require change if the default folder names are used.

 ![image](images%2Fimage.png)  

## 7. Install the ssl certificate

Before deploying the final application it is necessary to setup a SSL. Use lets-encrypt along with cert-manager and implement the SSLl
using Cluster issuer.

```bash
> helm repo add jetstack https://charts.jetstack.io
> helm repo update
> helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx -f helm/aks/nginx-ingress.yaml --set controller.service.externalTrafficPolicy=Local
```

Create a new file named clusterissuer.yaml.

```yaml

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: youremail
    privateKeySecretRef:
      name: letsencrypt
    solvers:
      - http01:
          ingress:
            class: nginx
  podTemplate:
    spec:
      nodeSelector:
        kubernetes.io/os: linux

```

Then apply this file

```bash
> kubectl apply -f clusterissuer.yaml
```

Create two new files named frontend-certificate.yaml and backend-certificate.yaml:

```yaml

apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tls-secret-frontend
  namespace: frontend
spec:
  secretName: tls-secret-frontend
  dnsNames:
    - transengine.eastus.cloudapp.azure.com
  issuerRef:
    name: letsencrypt
    kind: ClusterIssuer


```

```yaml

apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tls-secret-backend
  namespace: backend
spec:
  secretName: tls-secret-backend
  dnsNames:
    - transengine.eastus.cloudapp.azure.com
  issuerRef:
    name: letsencrypt
    kind: ClusterIssuer


```

Then apply these files:

```bash
> kubectl apply -f frontend-certificate.yaml 
> kubectl apply -f backend-certificate.yaml
```

Now in the values.yaml file update the ingress section of frontend and backend respectively. Add these lines in values.yaml in the ingress section
![image](images%2Fvalues-example.png)
![image](images%2Fvalues-backend.png)  

## 8. Install the `causal-services` chart

Now it's time to install our chart using the configuration file we just created:

```bash
> ./scripts/install-charts.sh helm/values.prod.yaml
```

## 9. Verify all services are properly running

```bash
> ./scripts/list-resources.sh
```

You should see the services up and running according to their namespace.

## 10. Access application

The application should now be available at: `https://{DOMAIN}`.
