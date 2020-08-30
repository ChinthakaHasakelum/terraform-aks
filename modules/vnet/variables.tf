variable "location" {}

variable "virtual_network_name" {}

variable "virtual_network_address_space" {}

variable "resource_group_name" {}

variable "environment" {}

variable "project" {}

variable "default_tags" {}

variable "private_dns_zones" {
  description = "Private DNS zone map"
  type        = list(map(string))
  default     = []
}

