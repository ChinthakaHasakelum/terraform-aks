resource "azurerm_sql_database" "db" {
  name                             = var.db_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  edition                          = var.db_edition 
  collation                        = var.collation 
  server_name                      = azurerm_sql_server.server.name 
  create_mode                      = "Default"
  requested_service_objective_name =  var.service_objective_name 
  tags                             =  var.tags 
}

resource "azurerm_sql_server" "server" {
  name                         =  join("-", [var.project, var.environment,"sql"]) 
  resource_group_name          =  var.resource_group_name 
  location                     =  var.location 
  version                      =  var.server_version 
  administrator_login          =  var.sql_admin_username 
  administrator_login_password =  var.sql_password 
  tags                         =  var.tags 
}