resource "azurerm_resource_group" "freshrss-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "freshrss-sa" {
  name                            = var.storage_account.name
  resource_group_name             = azurerm_resource_group.freshrss-rg.name
  location                        = azurerm_resource_group.freshrss-rg.location
  account_tier                    = var.storage_account.account_tier
  account_replication_type        = var.storage_account.account_replication_type
  min_tls_version                 = var.storage_account.min_tls_version
  public_network_access_enabled   = var.storage_account.public_network_access_enabled
  allow_nested_items_to_be_public = var.storage_account.allow_nested_items_to_be_public
  tags                            = var.tags
}

resource "azurerm_storage_container" "freshrss-container" {
  name                 = local.container_name
  storage_account_name = azurerm_storage_account.freshrss-sa.name
}

# TODO: firewalls, AKS cluster, AKS node pool,..
resource "azurerm_virtual_network" "fressrss-vnet" {
  name                = local.vnet_name
  location            = azurerm_resource_group.freshrss-rg.location
  resource_group_name = azurerm_resource_group.freshrss-rg.name
  address_space       = local.vnet_cidr
  tags                = var.tags
}

resource "azurerm_subnet" "freshrss-subnet" {
  name                 = local.subnet.name
  address_prefixes     = local.subnet.address_prefixes
  resource_group_name  = azurerm_resource_group.freshrss-rg.name
  virtual_network_name = azurerm_virtual_network.fressrss-vnet.name
}

resource "azurerm_kubernetes_cluster" "freshrss-aks" {
  name                = local.aks_cluster_name
  location            = azurerm_resource_group.freshrss-rg.location
  resource_group_name = azurerm_resource_group.freshrss-rg.name
  dns_prefix          = local.aks_dns_prefix
  sku_tier            = local.aks_sku_tier
  tags                = var.tags

  network_profile {
    network_plugin = var.aks_network_profile.network_plugin
    service_cidr   = var.aks_network_profile.service_cidr
    dns_service_ip = var.aks_network_profile.dns_service_ip
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = var.aks_default_node_pool.name
    node_count     = var.aks_default_node_pool.node_count
    vm_size        = var.aks_default_node_pool.vm_size
    vnet_subnet_id = azurerm_subnet.freshrss-subnet.id
  }
}
