variable "resource_group_name" {
  description = "The resource group name to be imported"
}

## Virtual Network
variable "virtual_network_address_space" {
  description = "The CIDR of the Virtual Network"
  type        = string
  }

variable "project" {
  description = "The name of the project"
  type        = string
 
}

variable "environment" {
  description = "The name of the environment e.g. staging,prod"
  type        = string
  
}


variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
}

variable "kubernetes_version" {
  description = "kubernetes version"
}

variable "api_server_authorized_ip_ranges" {

  description = "The IP ranges to whitelist for incoming traffic to the masters."
  
}

variable "client_id" {
  description = "The Client ID (appId) for the Service Principal used for the AKS deployment"
}

variable "client_secret" {
  description = "The Client Secret (password) for the Service Principal used for the AKS deployment"
}

variable "admin_username" {
  description = "The username of the local administrator to be created on the Kubernetes cluster"
}

variable "agents_size" {
  description = "The default virtual machine size for the Kubernetes agents"
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
}

variable "agents_count" {
  description = "The number of Agents that should exist in the Agent Pool"
  
}

variable "default_node_pool_orchestrator_version" {}

variable "kube_dashboard_enabled" {}

variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  default     = ""
}

variable "aks_public_ssh_key_path" {
  description = "A custom ssh key to control access to the AKS cluster"
  default     = ""
}

variable "aks_node_pool_subnet_address_prefix" {}

variable "os_disk_size_gb" {}

variable "enable_auto_scaling" {}

variable "default_node_pool_max_count" {}

variable "default_node_pool_min_count" {}

variable "service_cidr" {
  description = "AKS Cluster Service CIDR"
  type        = string
}

variable "dns_service_ip" {
  description = "AKS Cluster DNS Service IP"
  type        = string
}

variable "docker_bridge_cidr" {
  description = "AKS Cluster Docker bridge CIDR"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default     = {}
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}

## Bastion
variable "bastion_admin_username" {
  description = "Bastion admin username"
  type        = string
}

variable "bastion_managed_disk_size_gb" {
  description = "Bastion attached managed disk size"
  type        = string
}

variable "bastion_nsg_source_address_prefixes" {
  description = "Bastion NSG allowed public prefixed"
  type        = list(string)
}

variable "bastion_os_disk_size_gb" {
  description = "Bastion OS disk size"
  type        = string
}

variable "bastion_public_key_path" {
  description = "Bastion Public Key path"
  type        = string
}

variable "bastion_size" {
  description = "Bastion VM size"
  type        = string
}

variable "bastion_subnet_address_prefix" {
  description = "Bastion subnet address prefix"
  type        = string
}



### Private endpoint subnet
variable "private_endpoint_subnet_address_prefix" {
  description = "Private Endpoint Subnet Address Prefix"
  type        = string
}


variable "db_name" {
  description = "The name of the database to be created."
}

variable "db_edition" {
  description = "The edition of the database to be created."
  default     = "Basic"
}

variable "service_objective_name" {
  description = "The performance level for the database. For the list of acceptable values, see https://docs.microsoft.com/en-gb/azure/sql-database/sql-database-service-tiers. Default is Basic."
  default     = "Basic"
}

variable "collation" {
  description = "The collation for the database. Default is SQL_Latin1_General_CP1_CI_AS"
  default     = "SQL_Latin1_General_CP1_CI_AS"
}


variable "sql_admin_username" {
  description = "The administrator username of the SQL Server."
}


variable "sql_password" {
  description = "The administrator password of the SQL Server."
}

variable "server_version" {
  description = "The version for the database server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
  default     = "12.0"
}