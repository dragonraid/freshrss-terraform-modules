output "kube_config" {
  value       = azurerm_kubernetes_cluster.freshrss.kube_config_raw
  description = "Kubeconfig for the AKS cluster"
  sensitive   = true
}
