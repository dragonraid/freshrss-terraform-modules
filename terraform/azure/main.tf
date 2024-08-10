data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "freshrss" {
  name     = var.name
  location = var.location
}

# TODO: firewalls, AKS cluster, AKS node pool,..
resource "azurerm_virtual_network" "freshrss" {
  name                = var.name
  location            = azurerm_resource_group.freshrss.location
  resource_group_name = azurerm_resource_group.freshrss.name
  address_space       = var.vnet_cidr
  tags                = var.tags
}

resource "azurerm_subnet" "freshrss" {
  name                 = var.name
  address_prefixes     = var.subnet_address_prefixes
  resource_group_name  = azurerm_resource_group.freshrss.name
  virtual_network_name = azurerm_virtual_network.freshrss.name
}

resource "azurerm_kubernetes_cluster" "freshrss" {
  name                      = var.name
  location                  = azurerm_resource_group.freshrss.location
  resource_group_name       = azurerm_resource_group.freshrss.name
  dns_prefix                = var.name
  sku_tier                  = var.aks_sku_tier
  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  # TODO: Better handle tags
  tags = var.tags

  # TODO make optional maybe
  web_app_routing {
    dns_zone_id = ""
  }

  network_profile {
    network_plugin = var.aks_network_profile.network_plugin
    service_cidr   = var.aks_network_profile.service_cidr
    dns_service_ip = var.aks_network_profile.dns_service_ip
  }

  identity {
    type = local.aks_identity
  }

  default_node_pool {
    name           = var.aks_default_node_pool.name
    node_count     = var.aks_default_node_pool.node_count
    vm_size        = var.aks_default_node_pool.vm_size
    vnet_subnet_id = azurerm_subnet.freshrss.id
  }
}
