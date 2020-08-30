locals {
  default_tags = {
    project     = var.project
    environment = var.environment
    terraform   = "true"
  }

  private_dns_zone_name_sql     = "privatelink.sql.database.azure.com"

}
