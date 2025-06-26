#!/bin/bash

# Variables for Container Instance deployment
RESOURCE_GROUP="az-204-aci-test-RG"
LOCATION="westus"
ACR_NAME="az204acidemo$(date +%s)"  # Unique name with timestamp
CONTAINER_NAME="weather-api-aci"
IMAGE_NAME="weather-api"
IMAGE_TAG="latest"
DNS_NAME_LABEL="weather-api-aci-$(date +%s)"  # Unique DNS label

# Step 1: Create Resource Group
echo "Creating resource group for Container Instance..."
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

# Step 5: Deploy Container Instance
echo "Creating Azure Container Instance..."
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME \
  --image ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} \
  --registry-login-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --dns-name-label $DNS_NAME_LABEL \
  --ports 8080 \
  --cpu 1 \
  --memory 1.5 \
  --environment-variables "ASPNETCORE_ENVIRONMENT=Development" \
  --location $LOCATION

# Step 6: Get the Container Instance details
echo "Getting Container Instance details..."
FQDN=$(az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --query ipAddress.fqdn --output tsv)
IP_ADDRESS=$(az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --query ipAddress.ip --output tsv)

echo "Container Instance deployed successfully!"
echo "FQDN: $FQDN"
echo "IP Address: $IP_ADDRESS"
echo "Access your application at: http://$FQDN:8080"

# Optional: Show container logs
echo "Container logs:"
az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME