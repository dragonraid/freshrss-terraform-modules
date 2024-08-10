# FreshRSS

Terraform module for deploying a self-hosted instance of [FreshRSS](https://freshrss.github.io/FreshRSS/en/) to kubernetes in azure public cloud.

> [!IMPORTANT]
> This module is meant to be simple and cheap not highly available and secure

## Quick start

This guide presumes you have following basic understanding of the following:

- AKS
- terraform
- azure CLI
- kubectl
- kustomize

### Prerequisites

- Azure account with existing subscription
- [azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)
- [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deploy

Following part resembles the example values you can use to deploy the FreshRSS instance to Azure.

```bash
cat << EOF > main.tf
module "freshrss" {
  source = "git::https://github.com/dragonraid/freshrss-terraform-modules/terraform/azure"

  location              = "North Europe"
  aks_default_node_pool = {}
  aks_network_profile   = {}
}
EOF

cat << EOF > provider.tf
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.110.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
}
EOF
```

Then run following commands to deploy the FreshRSS instance to Azure.

```bash
az login

terraform init
terraform apply
terraform output -raw kube_config > /tmp/kubeconfig 
KUBECONFIG=/tmp/kubeconfig:~/.kube/config kubectl config view --flatten > ~/.kube/config
kubectl apply -k modules/kubernetes/base
```

Get the external IP of the FreshRSS instance by running following command.

```bash
kubectl get ingress freshrss -n freshrss -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Happy reading!

## Terraform

### Inputs

| Name                      | Description                                                 | Type     | Default       | Required |
| ------------------------- | ----------------------------------------------------------- | -------- | ------------- | -------- |
| name                      | Name of the stack referenced in resource names.             | string   | `freshrss`    | no       |
| location                  | The Azure region in which to deploy the FreshRSS resources. | `string` | n/a           | yes      |
| vnet_cidr                 | Azure VNET address prefix.                                  | string   | `10.0.0.0/24` | no       |
| subnet_address_prefixes   | Azure subent address prefix.                                | string   | `10.0.0.0/24` | no       |
| aks_sku_tier              | The SKU tier of the AKS cluster.                            | string   | `Free`        | no       |
| workload_identity_enabled | Enable workload identity for the AKS cluster.               | bool     | `false`       | no       |
| oidc_issuer_enabled       | Enable OIDC issuer for the AKS cluster.                     | bool     | `false`       | no       |
| aks_default_node_pool*    | The AKS default node pool configuration.                    | object   | `{}`          | no       |
| aks_network_profile*      | The AKS network profile configuration.                      | object   | `{}`          | no       |

> \* See below for more information.

#### aks_default_node_pool

| Name       | Description                                   | Type   | Default        | Required |
| ---------- | --------------------------------------------- | ------ | -------------- | -------- |
| name       | The name of the default node pool.            | string | `default`      | no       |
| node_count | The number of nodes in the default node pool. | number | `1`            | no       |
| vm_size    | The size of the Virtual Machine.              | string | `Standard_B2s` | no       |

#### aks_network_profile

| Name           | Description                                  | Type   | Default         | Required |
| -------------- | -------------------------------------------- | ------ | --------------- | -------- |
| network_plugin | The network plugin used for the AKS cluster. | string | `azure`         | no       |
| service_cidr   | The service CIDR used for the AKS cluster.   | string | `172.32.0.0/12` | no       |
| dns_service_ip | The DNS service IP used for the AKS cluster. | string | `172.32.0.2`    | no       |

### Outputs

| Name           | Description                                  | Type   |
| -------------- | -------------------------------------------- | ------ |
| kube_config    | The kubeconfig file for the AKS cluster.     | string |