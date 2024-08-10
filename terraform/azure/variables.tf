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
    service = "freshrss"
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

variable "aks_sku_tier" {
  type    = string
  default = "Free"
}

variable "workload_identity_enabled" {
  type    = bool
  default = false
}

variable "oidc_issuer_enabled" {
  type    = bool
  default = false
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
