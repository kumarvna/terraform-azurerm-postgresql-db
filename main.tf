#------------------------------------------------------------
# Local configuration - Default (required). 
#------------------------------------------------------------
locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  mysqlserver_settings = defaults(var.postgresql_server_settings, {
    charset   = "UTF8"
    collation = "English_United States.1252"
  })
}

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

#---------------------------------------------------------
# Storage Account to keep Audit logs - Default is "false"
#----------------------------------------------------------
resource "random_string" "str" {
  count   = var.enable_threat_detection_policy ? 1 : 0
  length  = 6
  special = false
  upper   = false
  keepers = {
    name = var.storage_account_name
  }
}

resource "azurerm_storage_account" "storeacc" {
  count                     = var.enable_threat_detection_policy ? 1 : 0
  name                      = var.storage_account_name == null ? "stsqlauditlogs${element(concat(random_string.str.*.result, [""]), 0)}" : substr(var.storage_account_name, 0, 24)
  resource_group_name       = local.resource_group_name
  location                  = local.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = merge({ "Name" = format("%s", "stsqlauditlogs") }, var.tags, )
}

resource "random_password" "main" {
  count       = var.admin_password == null ? 1 : 0
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    administrator_login_password = var.postgresql_server_name
  }
}

#----------------------------------------------------------------
# Adding  PostgreSQL Server creation and settings - Default is "True"
#-----------------------------------------------------------------
resource "azurerm_postgresql_server" "main" {
  name                              = format("%s", var.postgresql_server_name)
  resource_group_name               = local.resource_group_name
  location                          = local.location
  administrator_login               = var.admin_username == null ? "postgresadmin" : var.admin_username
  administrator_login_password      = var.admin_password == null ? random_password.main.0.result : var.admin_password
  sku_name                          = var.postgresql_server_settings.sku_name
  version                           = var.postgresql_server_settings.version
  storage_mb                        = var.postgresql_server_settings.storage_mb
  auto_grow_enabled                 = var.postgresql_server_settings.auto_grow_enabled
  backup_retention_days             = var.postgresql_server_settings.backup_retention_days
  geo_redundant_backup_enabled      = var.postgresql_server_settings.geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.postgresql_server_settings.infrastructure_encryption_enabled
  public_network_access_enabled     = var.postgresql_server_settings.public_network_access_enabled
  ssl_enforcement_enabled           = var.postgresql_server_settings.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.postgresql_server_settings.ssl_minimal_tls_version_enforced
  create_mode                       = var.create_mode
  creation_source_server_id         = var.create_mode != "Default" ? var.creation_source_server_id : null
  restore_point_in_time             = var.create_mode == "PointInTimeRestore" ? var.restore_point_in_time : null
  tags                              = merge({ "Name" = format("%s", var.postgresql_server_name) }, var.tags, )

  dynamic "identity" {
    for_each = var.identity == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }

  dynamic "threat_detection_policy" {
    for_each = var.enable_threat_detection_policy == true ? [1] : []
    content {
      enabled                    = var.enable_threat_detection_policy
      disabled_alerts            = var.disabled_alerts
      email_account_admins       = var.email_addresses_for_alerts != null ? true : false
      email_addresses            = var.email_addresses_for_alerts
      retention_days             = var.log_retention_days
      storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
      storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
    }
  }
}

#------------------------------------------------------------
# Adding  PostgreSQL Server Database - Default is "true"
#------------------------------------------------------------
resource "azurerm_postgresql_database" "main" {
  name                = var.postgresql_server_settings.database_name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_postgresql_server.main.name
  charset             = var.postgresql_server_settings.charset
  collation           = var.postgresql_server_settings.collation
}

