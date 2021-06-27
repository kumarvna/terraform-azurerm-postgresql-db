output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = module.postgresql-db.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = module.postgresql-db.resource_group_location
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.postgresql-db.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.postgresql-db.storage_account_name
}

output "postgresql_server_id" {
  description = "The ID of the PostgreSQL Server"
  value       = module.postgresql-db.postgresql_server_id
}

output "postgresql_server_fqdn" {
  description = "The FQDN of the PostgreSQL Server"
  value       = module.postgresql-db.postgresql_server_fqdn
}

output "postgresql_database_id" {
  description = "The ID of the PostgreSQL Database"
  value       = module.postgresql-db.postgresql_database_id
}
