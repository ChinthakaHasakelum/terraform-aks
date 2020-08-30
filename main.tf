provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

module "private-dns-sql" {
  source                = "./modules/private-dns-zone"
  default_tags          = local.default_tags
  private_dns_zone_name = local.private_dns_zone_name_sql
  resource_group_name   = var.resource_group_name
}

module "virtual-network" {
  source                        = "./modules/vnet"
  resource_group_name           = var.resource_group_name
  location                      = data.azurerm_resource_group.main.location
  project                       = var.project
  environment                   = var.environment
  virtual_network_name          = join("-", [var.project, var.environment, "vnet"])
  virtual_network_address_space = var.virtual_network_address_space
  default_tags                  = var.tags
   private_dns_zones = [
     { name = "sql", zone_name = local.private_dns_zone_name_sql },
  #   { name = "file", zone_name = local.private_dns_zone_name_fileshare },
  #   { name = "eventhub", zone_name = local.private_dns_zone_name_eventhub },
   ]
}

# Create Private Endpoint Subnet
module "private-endpoint-subnet" {
  source               = "./modules/private-endpoint-subnet"
  address_prefixes     = var.private_endpoint_subnet_address_prefix
  default_tags         = local.default_tags
  environment          = var.environment
  location             = data.azurerm_resource_group.main.location
  project              = var.project
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.virtual-network.virtual_network_name
}


# Bastion
module "bastion" {
  source                      = "./modules/bastion"
  admin_username              = var.bastion_admin_username
  default_tags                = local.default_tags
  environment                 = var.environment
  location                    = data.azurerm_resource_group.main.location
  managed_disk_size_gb        = var.bastion_managed_disk_size_gb
  nsg_source_address_prefixes = var.bastion_nsg_source_address_prefixes
  os_disk_size_gb             = var.bastion_os_disk_size_gb
  project                     = var.project
  public_key_path             = var.bastion_public_key_path
  resource_group_name         = var.resource_group_name
  size                        = var.bastion_size
  subnet_address_prefix       = var.bastion_subnet_address_prefix
  virtual_network_name        = module.virtual-network.virtual_network_name
  
}


# SQLServer
module "sqlserver" {
  source                      = "./modules/sqlserver"
  resource_group_name         = var.resource_group_name
  location                    = data.azurerm_resource_group.main.location
  server_version              = var.server_version
  db_name                     = var.db_name
  sql_admin_username          = var.sql_admin_username
  sql_password                = var.sql_password
  environment                 = var.environment
  service_objective_name      = var.service_objective_name
  project                     = var.project
  private_endpoint_subnets    = [module.private-endpoint-subnet.private_endpoint_subnet_id]
  db_edition                  = var.db_edition
  tags                        = local.default_tags
  private_dns_zone_ids        = [module.private-dns-sql.private_dns_zone_id]

  
}


resource "azurerm_kubernetes_cluster" "main" {

  depends_on          = [
    azurerm_subnet.aks_node_pool_subnet
  ]


  name                = "${var.prefix}-aks"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.prefix
  kubernetes_version  = var.kubernetes_version
  api_server_authorized_ip_ranges   = var.api_server_authorized_ip_ranges
  node_resource_group = "MC_abb-northstar-iam-wso2-stage-we-rg-001_aks_westeurope"

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      # remove any new lines using the replace interpolation function
      key_data      = file(var.aks_public_ssh_key_path)
      #key_data = replace(var.public_ssh_key == "" ? file(var.aks_public_ssh_key_path): var.public_ssh_key, "\n", "")
    }
  }

  default_node_pool {
    name                            = "nodepool"
    node_count                      = var.agents_count
    vnet_subnet_id                  = azurerm_subnet.aks_node_pool_subnet.id
    vm_size                         = var.agents_size
    os_disk_size_gb                 = var.os_disk_size_gb
    enable_auto_scaling             = var.enable_auto_scaling
    max_count                       = var.default_node_pool_max_count
    min_count                       = var.default_node_pool_min_count
    orchestrator_version            = var.default_node_pool_orchestrator_version
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  dynamic addon_profile {
    for_each = var.enable_log_analytics_workspace ? ["log_analytics"] : []
    content {
      oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id
      }

          kube_dashboard {
        enabled                  = var.kube_dashboard_enabled
    }
    }

    
  }

    network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr

    # load_balancer_profile {
    #     outbound_ip_prefix_ids     = [azurerm_public_ip_prefix.public_ip_prefix_lb_outbound.id]
    #     outbound_ports_allocated   = var.lb_outbound_ports_allocated
    #     idle_timeout_in_minutes    = 4
    # }
  }

  tags = var.tags
}


resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enable_log_analytics_workspace ? 1 : 0
  name                = "${var.prefix}-workspace"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "main" {
  count                 = var.enable_log_analytics_workspace ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main[0].id
  workspace_name        = azurerm_log_analytics_workspace.main[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


