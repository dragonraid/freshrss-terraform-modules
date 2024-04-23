locals {
  aks_identity                         = "SystemAssigned"
  aks_http_application_routing_enabled = true
  federated_identity_audience          = ["api://AzureADTokenExchange"]
  federated_identity_subject_prefix    = "system:serviceaccount"
}
