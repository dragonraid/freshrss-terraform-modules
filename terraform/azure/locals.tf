locals {
  aks_identity                         = "SystemAssigned"
  federated_identity_audience          = ["api://AzureADTokenExchange"]
  federated_identity_subject_prefix    = "system:serviceaccount"
}
