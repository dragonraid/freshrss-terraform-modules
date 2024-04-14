# TODO: change this to variables
locals {
  container_name = "data"

  # TODO: smaller subnets!!!
  vnet_name = "fressrss-vnet"
  vnet_cidr = ["10.0.0.0/16"]
  subnet    = { name : "subnet1", address_prefixes : ["10.0.0.0/24"] }

  aks_cluster_name = "freshrss-aks"
  aks_dns_prefix   = "freshrss"
  aks_sku_tier     = "Free"
}
