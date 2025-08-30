# ${{ values.name }} - Terraform Azure Infrastructure

${{ values.description }}

This repository contains Terraform configuration for deploying Azure infrastructure.

## Prerequisites

- Terraform installed (version >= 1.0)
- Azure CLI installed and configured
- Azure subscription with appropriate permissions

## Setup

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Review the plan**
   ```bash
   terraform plan
   ```

3. **Apply the configuration**
   ```bash
   terraform apply
   ```

## Configuration

### Required Variables

Create a `terraform.tfvars` file with the following variables:

```hcl
resource_group_name = "${{ values.resourceGroupName }}"
location           = "${{ values.location }}"
app_name          = "${{ values.name }}"
```

### Optional Variables

You can also customize:
- App Service Plan SKU
- Storage account replication type
- Container registry settings

## Resources Created

- **Resource Group** - Contains all resources
- **App Service Plan** - Linux-based hosting plan
- **Linux Web App** - Web application with Node.js runtime
- **Storage Account** - For static websites and file storage
- **Container Registry** - For containerized applications

## Outputs

The configuration provides:
- `web_app_url` - URL of the deployed web application
- `storage_account_name` - Name of the storage account
- `container_registry_name` - Name of the container registry
- `resource_group_name` - Name of the resource group

## State Management

For production use, configure remote state storage:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatestorage"
    container_name       = "terraform-state"
    key                  = "${{ values.name }}.terraform.tfstate"
  }
}
```

## Security Best Practices

- Use managed identities for service authentication
- Enable diagnostic logging
- Implement network security groups
- Use Azure Key Vault for secrets management

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```