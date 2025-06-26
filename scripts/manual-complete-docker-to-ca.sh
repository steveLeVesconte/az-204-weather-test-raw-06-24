#!/bin/bash

# Variables for Container Apps deployment
RESOURCE_GROUP="az-204-aci-test-RG"  # Reusing same resource group
LOCATION="westus"
ACR_NAME="az204academo$(date +%s)"  # Unique ACR name for Container Apps
CONTAINER_APP_NAME="weather-api-ca"
CONTAINER_APP_ENV_NAME="weather-api-env"
IMAGE_NAME="weather-api"
IMAGE_TAG="latest"

# Step 1: Create or verify Resource Group (idempotent)
echo "Creating/verifying resource group for Container Apps..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Step 2: Create Azure Container Registry
echo "Creating Azure Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

#   CD to Root of the project directory!!!!!!!!!!!!!!!!!!!!

# Step 3: Build and push Docker image
echo "Building and pushing Docker image..."
# Build the Docker image locally first
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# Tag the image for ACR
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}

# Login to ACR and push
az acr login --name $ACR_NAME
docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}

# Alternative: Build directly in ACR (recommended for production)
# az acr build --registry $ACR_NAME --image ${IMAGE_NAME}:${IMAGE_TAG} .

# Step 4: Get ACR credentials
echo "Retrieving ACR credentials..."
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)

echo "ACR Details:"
echo "Login Server: $ACR_LOGIN_SERVER"
echo "Image: ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

# Step 5: Create Container Apps Environment
echo "Creating Container Apps Environment..."
az containerapp env create \
  --name $CONTAINER_APP_ENV_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Step 6: Deploy Container App
echo "Creating Azure Container App..."
az containerapp create \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINER_APP_ENV_NAME \
  --image ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} \
  --registry-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress external \
  --cpu 1.0 \
  --memory 2.0Gi \
  --min-replicas 1 \
  --max-replicas 3 \
  --env-vars "ASPNETCORE_ENVIRONMENT=Development"

# Step 7: Get the Container App details
echo "Getting Container App details..."
FQDN=$(az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn --output tsv)

echo "Container App deployed successfully!"
echo "FQDN: $FQDN"
echo "Access your application at: https://$FQDN"
echo "Swagger UI available at: https://$FQDN/swagger"

# Step 8: Show Container App status and logs
echo "Container App status:"
az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --query properties.runningStatus --output tsv

echo "Recent container logs:"
az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --follow false