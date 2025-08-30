# ${{ values.name }} - Azure Infrastructure

${{ values.description }}

This repository contains Azure infrastructure as code using Bicep templates.

## Prerequisites

- Azure CLI installed and configured
- Azure subscription with appropriate permissions
- Resource group: `${{ values.resourceGroupName }}`

## Deployment

### Using Azure CLI

```bash
# Login to Azure
az login

# Create resource group (if it doesn't exist)
az group create --name ${{ values.resourceGroupName }} --location "${{ values.location }}"

# Deploy the infrastructure
az deployment group create \
  --resource-group ${{ values.resourceGroupName }} \
  --template-file bicep/main.bicep \
  --parameters appName=${{ values.name }}
```

### Using Azure DevOps Pipeline

See the included pipeline configuration for automated deployments.

## Resources Created

- **App Service Plan** - Hosting plan for the web application
- **Web App** - Linux-based web application
- **Storage Account** - For static assets and file storage

## Configuration

The infrastructure creates:
- A Linux App Service Plan with Node.js runtime
- A Web Application configured for Node.js 18
- A Storage Account for static website hosting

## Outputs

After deployment, the following information will be available:
- Web App URL
- Storage Account Name
- Resource Group Name

## Monitoring

The deployed infrastructure includes:
- Application Insights (optional)
- Log Analytics workspace (optional)
- Health checks and monitoring endpoints

## Security

- HTTPS enforced by default
- Managed identity for secure resource access
- Network security groups for traffic control