# Azure Database for PostgreSQL Terraform Module

Azure Database for PostgreSQL Single Server is a fully managed database service with minimal requirements for customizations of database. The single server platform is designed to handle most of the database management functions such as patching, backups, high availability, security with minimal user configuration and control. The architecture is optimized for built-in high availability with 99.99% availability on single availability zone. It supports community version of PostgreSQL 9.5, 9,6, 10, and 11.

## Module Usage (PostgreSQL with optional resrouces)

```terraform
module "postgresql-db" {
  source  = "kumarvna/postgresql-db/azurerm"
  version = "1.1.0"

  # By default, this module will create a resource group
  # proivde a name to use an existing resource group and set the argument 
  # to `create_resource_group = false` if you want to existing resoruce group. 
  # If you use existing resrouce group location will be the same as existing RG.
  create_resource_group = false
  resource_group_name   = "rg-shared-westeurope-01"
  location              = "westeurope"

  # PostgreSQL Server and Database settings
  postgresql_server_name = "mypostgresdbsrv01"

  postgresql_server_settings = {
    sku_name   = "GP_Gen5_8"
    storage_mb = 640000
    version    = "9.6"
    # default admin user `postgresadmin` and can be specified as per the choice here
    # by default random password created by this module. required password can be specified here
    admin_username = "postgresadmin"
    admin_password = "H@Sh1CoR3!"
    # Database name, charset and collection arguments  
    database_name = "demo-postgres-db"
    charset       = "UTF8"
    collation     = "English_United States.1252"
    # Storage Profile and other optional arguments
    auto_grow_enabled                = true
    backup_retention_days            = 7
    geo_redundant_backup_enabled     = true
    public_network_access_enabled    = true
    ssl_enforcement_enabled          = true
    ssl_minimal_tls_version_enforced = "TLS1_2"
  }

  # PostgreSQL Server Parameters 
  # For more information: https://bit.ly/3dbYTtB
  postgresql_configuration = {
    backslash_quote = "on"
  }

  # Use Virtual Network service endpoints and rules for Azure Database for PostgreSQL
  subnet_id = var.subnet_id

  # The URL to a Key Vault custom managed key
  key_vault_key_id = var.key_vault_key_id

  # To enable Azure Defender for database set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30
  email_addresses_for_alerts     = ["user@example.com", "firstname.lastname@example.com"]

  # AD administrator for an Azure database for PostgreSQL
  # Allows you to set a user or group as the AD administrator for PostgreSQL server
  ad_admin_login_name = "firstname.lastname@example.com"

  # (Optional) To enable Azure Monitoring for Azure PostgreSQL database
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage. 
  log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Firewall Rules to allow azure and external clients and specific Ip address/ranges. 
  firewall_rules = {
    access-to-azure = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    desktop-ip = {
      start_ip_address = "49.204.228.223"
      end_ip_address   = "49.204.228.223"
    }
  }

  # Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

## Module Usage (PostgreSQL with private link and optional resrouces)

```terraform
module "postgresql-db" {
  source  = "kumarvna/postgresql-db/azurerm"
  version = "1.1.0"

  # By default, this module will create a resource group
  # proivde a name to use an existing resource group and set the argument 
  # to `create_resource_group = false` if you want to existing resoruce group. 
  # If you use existing resrouce group location will be the same as existing RG.
  create_resource_group = false
  resource_group_name   = "rg-shared-westeurope-01"
  location              = "westeurope"

  # PostgreSQL Server and Database settings
  postgresql_server_name = "mypostgresdbsrv01"

  postgresql_server_settings = {
    sku_name   = "GP_Gen5_8"
    storage_mb = 640000
    version    = "9.6"
    # default admin user `postgresadmin` and can be specified as per the choice here
    # by default random password created by this module. required password can be specified here
    admin_username = "postgresadmin"
    admin_password = "H@Sh1CoR3!"
    # Database name, charset and collection arguments  
    database_name = "demo-postgres-db"
    charset       = "UTF8"
    collation     = "English_United States.1252"
    # Storage Profile and other optional arguments
    auto_grow_enabled                = true
    backup_retention_days            = 7
    geo_redundant_backup_enabled     = true
    public_network_access_enabled    = true
    ssl_enforcement_enabled          = true
    ssl_minimal_tls_version_enforced = "TLS1_2"
  }

  # PostgreSQL Server Parameters 
  # For more information: https://bit.ly/3dbYTtB
  postgresql_configuration = {
    backslash_quote = "on"
  }

  # Use Virtual Network service endpoints and rules for Azure Database for PostgreSQL
  subnet_id = var.subnet_id

  # The URL to a Key Vault custom managed key
  key_vault_key_id = var.key_vault_key_id

  # To enable Azure Defender for database set `enable_threat_detection_policy` to true 
  enable_threat_detection_policy = true
  log_retention_days             = 30
  email_addresses_for_alerts     = ["user@example.com", "firstname.lastname@example.com"]

  # AD administrator for an Azure database for PostgreSQL
  # Allows you to set a user or group as the AD administrator for PostgreSQL server
  ad_admin_login_name = "firstname.lastname@example.com"

  # (Optional) To enable Azure Monitoring for Azure PostgreSQL database
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage. 
  log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Creating Private Endpoint requires, VNet name and address prefix to create a subnet
  # By default this will create a `privatelink.mysql.database.azure.com` DNS zone. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  enable_private_endpoint       = true
  virtual_network_name          = "vnet-shared-hub-westeurope-001"
  private_subnet_address_prefix = ["10.1.5.0/29"]
  #  existing_private_dns_zone     = "demo.example.com"

  # Firewall Rules to allow azure and external clients and specific Ip address/ranges. 
  firewall_rules = {
    access-to-azure = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    desktop-ip = {
      start_ip_address = "49.204.228.223"
      end_ip_address   = "49.204.228.223"
    }
  }

  # Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
```

## Terraform Usage

To run this example you need to execute following Terraform commands

```hcl
terraform init

terraform plan

terraform apply
```

Run `terraform destroy` when you don't need these resources.

## Outputs

| Name | Description |
|--|--|
`resource_group_name`|The name of the resource group in which resources are created
`resource_group_location`|The location of the resource group in which resources are created
`storage_account_id`|The resource ID of the storage account
`storage_account_name`|The name of the storage account
`postgresql_server_id`|The resource ID of the PostgreSQL Server
`postgresql_server_fqdn`|The FQDN of the PostgreSQL Server
`postgresql_database_id`|The ID of the PostgreSQL Database
`postgresql_server_private_endpoint`|id of the PostgreSQL server Private Endpoint
`postgresql_server_private_dns_zone_domain`|DNS zone name of PostgreSQL server Private endpoints dns name records
`postgresql_server_private_endpoint_ip`|PostgreSQL server private endpoint IPv4 Addresses
`postgresql_server_private_endpoint_fqdn`|PostgreSQL server private endpoint FQDN Addresses
