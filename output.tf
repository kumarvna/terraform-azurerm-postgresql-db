output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = local.location
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = element(concat(azurerm_storage_account.storeacc.*.id, [""]), 0)
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = element(concat(azurerm_storage_account.storeacc.*.name, [""]), 0)
}

output "postgresql_server_id" {
  description = "The ID of the PostgreSQL Server"
  value       = azurerm_postgresql_server.main.id
}

output "postgresql_server_fqdn" {
  description = "The FQDN of the PostgreSQL Server"
  value       = azurerm_postgresql_server.main.fqdn
}

output "postgresql_database_id" {
  description = "The ID of the PostgreSQL Database"
  value       = azurerm_postgresql_database.main.id
}

output "postgresql_server_private_endpoint" {
  description = "id of the PostgreSQL server Private Endpoint"
  value       = var.enable_private_endpoint ? element(concat(azurerm_private_endpoint.pep1.*.id, [""]), 0) : null
}

output "postgresql_server_private_dns_zone_domain" {
  description = "DNS zone name of PostgreSQL server Private endpoints dns name records"
  value       = var.existing_private_dns_zone == null && var.enable_private_endpoint ? element(concat(azurerm_private_dns_zone.dnszone1.*.name, [""]), 0) : var.existing_private_dns_zone
}

output "postgresql_server_private_endpoint_ip" {
  description = "PostgreSQL server private endpoint IPv4 Addresses"
  value       = var.enable_private_endpoint ? element(concat(data.azurerm_private_endpoint_connection.private-ip1.*.private_service_connection.0.private_ip_address, [""]), 0) : null
}

output "postgresql_server_private_endpoint_fqdn" {
  description = "PostgreSQL server private endpoint FQDN Addresses"
  value       = var.enable_private_endpoint ? element(concat(azurerm_private_dns_a_record.arecord1.*.fqdn, [""]), 0) : null
}
