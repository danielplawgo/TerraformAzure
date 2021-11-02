terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "onlin-rg-${var.env}"
  location = var.resource_location
}

resource "azurerm_application_insights" "app_insight" {
  name                = "onlin-ai-${var.env}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "onlin-sp-${var.env}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  kind                = "app"

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
}

resource "azurerm_app_service" "app" {
  name                    = "onlin-app-${var.env}"
  location                = azurerm_resource_group.resource_group.location
  resource_group_name     = azurerm_resource_group.resource_group.name
  app_service_plan_id     = azurerm_app_service_plan.app_service_plan.id
  https_only              = true
  client_affinity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    dotnet_framework_version  = "v5.0"
    always_on                 = true
    use_32_bit_worker_process = false
    default_documents = [
      "index.html"
    ]
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE              = "1"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insight.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insight.connection_string
  }
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "onlin-sql-${var.env}"
  location                     = azurerm_resource_group.resource_group.location
  resource_group_name          = azurerm_resource_group.resource_group.name
  version                      = "12.0"
  administrator_login          = var.sql_server_login
  administrator_login_password = var.sql_server_password
  minimum_tls_version          = "1.2"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "sql_database" {
  name           = "onlin-sqldb-${var.env}"
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  read_scale     = false
  sku_name       = var.database_sku
  zone_redundant = false
}

resource "azurerm_sql_firewall_rule" "azure_services_firewall_rule" {
  name                = "azure_services_firewall_rule"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_mssql_server.sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}