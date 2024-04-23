variable "name" {
  type    = string
  default = "freshrss"
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    service = "freshrss" # TODO: make local and merge with custom tags
  }
}

variable "vnet_cidr" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

variable "subnet_address_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

variable "storage_account" {
  type = object({
    account_tier                     = optional(string, "Standard")
    account_replication_type         = optional(string, "LRS")
    container_name                   = optional(string, "data")
    min_tls_version                  = optional(string, "TLS1_2")
    cross_tenant_replication_enabled = optional(bool, false)
    public_network_access_enabled    = optional(bool, false)
    allow_nested_items_to_be_public  = optional(bool, false)
  })
}

variable "aks_sku_tier" {
  type    = string
  default = "Free"
}

variable "workload_identity_enabled" {
  type    = bool
  default = true
}

variable "oidc_issuer_enabled" {
  type    = bool
  default = true
}

variable "aks_default_node_pool" {
  type = object({
    name       = optional(string, "default")
    node_count = optional(number, 1)
    vm_size    = optional(string, "Standard_B2s")
  })
}

variable "aks_network_profile" {
  type = object({
    network_plugin = optional(string, "azure")
    service_cidr   = optional(string, "172.32.0.0/12")
    dns_service_ip = optional(string, "172.32.0.2")
  })
}
