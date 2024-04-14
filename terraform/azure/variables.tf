# Sweden Central seems to be the cheapest region
variable "location" {
  type = string
}

variable "resource_group_name" {
  type    = string
  default = "freshrss-rg"
}

variable "tags" {
  type = map(string)
  default = {
    service = "freshrss" # TODO: make local and merge with custom tags
  }
}

variable "storage_account" {
  type = object({
    name                             = optional(string, "freshrsssa")
    account_tier                     = optional(string, "Standard")
    account_replication_type         = optional(string, "LRS")
    min_tls_version                  = optional(string, "TLS1_2")
    cross_tenant_replication_enabled = optional(bool, false)
    public_network_access_enabled    = optional(bool, false)
    allow_nested_items_to_be_public  = optional(bool, false)
  })
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
