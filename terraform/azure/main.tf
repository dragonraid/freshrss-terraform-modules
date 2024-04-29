data "azurerm_subscription" "current" {} # TODO: Rename to current

resource "azurerm_resource_group" "freshrss" {
  name     = var.name
  location = var.location
}

resource "azurerm_storage_account" "freshrss" {
  name                            = var.name
  resource_group_name             = azurerm_resource_group.freshrss.name
  location                        = azurerm_resource_group.freshrss.location
  account_tier                    = var.storage_account.account_tier
  account_replication_type        = var.storage_account.account_replication_type
  min_tls_version                 = var.storage_account.min_tls_version
  public_network_access_enabled   = var.storage_account.public_network_access_enabled
  allow_nested_items_to_be_public = var.storage_account.allow_nested_items_to_be_public
  tags                            = var.tags
}

resource "azurerm_storage_container" "freshrss" {
  name                 = var.storage_account.container_name
  storage_account_name = azurerm_storage_account.freshrss.name
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
  name                             = var.name
  location                         = azurerm_resource_group.freshrss.location
  resource_group_name              = azurerm_resource_group.freshrss.name
  dns_prefix                       = var.name
  sku_tier                         = var.aks_sku_tier
  workload_identity_enabled        = var.workload_identity_enabled
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  # TODO: Better handle tags
  tags = var.tags

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

# TODO: Loose the suffixes (identity, role, role-assignment)
resource "azurerm_user_assigned_identity" "freshrss" {
  name                = var.name
  location            = azurerm_resource_group.freshrss.location
  resource_group_name = azurerm_resource_group.freshrss.name
  tags                = var.tags
}

resource "azurerm_role_definition" "freshrss" {
  name        = var.name
  scope       = data.azurerm_subscription.current.id
  description = "Allows FreshRSS to backup data to the storage account"

  # TODO: Permissions too wide!!!
  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}

resource "azurerm_role_assignment" "freshrss" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.freshrss.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.freshrss.principal_id
}

resource "azurerm_federated_identity_credential" "freshrss" {
  name                = var.name
  resource_group_name = azurerm_resource_group.freshrss.name
  audience            = local.federated_identity_audience # TODO: find out what is this
  issuer              = azurerm_kubernetes_cluster.freshrss.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.freshrss.id
  subject             = "system:serviceaccount:default:freshrss"
}
