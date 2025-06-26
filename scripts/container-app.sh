# script:
#!/bin/bash
# Variables
RESOURCE_GROUP="az-204-cli-demo"
LOCATION="westus"
ACR_NAME="az204clidemo$(date +%s)"  # Unique name with timestamp
APP_NAME="weather-api-cli"
ENVIRONMENT_NAME="ca-env-cli-demo"
IMAGE_NAME="weather-api"
IMAGE_TAG="latest"
# Step 1: Create Resource Group
echo "Creating resource group..."
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
# Step 4: Create Container Apps Environment
echo "Creating Container Apps Environment..."
az containerapp env create \
  --name $ENVIRONMENT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION
# Step 5: Deploy Container App using CLI
echo "Creating Container App with CLI..."

# Get ACR details
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)

echo "ACR Details:"
echo "Login Server: $ACR_LOGIN_SERVER"
echo "Image: ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

# Create the Container App
az containerapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT_NAME \
  --image ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} \
  --registry-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress external \
  --cpu 0.25 \
  --memory 0.5Gi \
  --min-replicas 1 \
  --max-replicas 3 \
  --env-vars "ASPNETCORE_ENVIRONMENT=Development"