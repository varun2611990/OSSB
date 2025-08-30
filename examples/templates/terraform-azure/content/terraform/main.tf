terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${{ values.resourceGroupName }}"
  location = "${{ values.location }}"

  tags = {
    Environment = "Development"
    Project     = "${{ values.name }}"
  }
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${{ values.name }}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "F1"

  tags = {
    Environment = "Development"
    Project     = "${{ values.name }}"
  }
}

# Linux Web App
resource "azurerm_linux_web_app" "main" {
  name                = "${{ values.name }}-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18.0.0"
  }

  tags = {
    Environment = "Development"
    Project     = "${{ values.name }}"
  }
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${replace("${{ values.name }}", "-", "")}stor${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  static_website {
    index_document = "index.html"
  }

  tags = {
    Environment = "Development"
    Project     = "${{ values.name }}"
  }
}

# Random ID for storage account name uniqueness
resource "random_id" "storage_suffix" {
  byte_length = 4
}

# Container Registry (optional for containerized apps)
resource "azurerm_container_registry" "main" {
  name                = "${replace("${{ values.name }}", "-", "")}acr${random_id.storage_suffix.hex}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Environment = "Development"
    Project     = "${{ values.name }}"
  }
}