output "azure_kubernetes_cluster_id_output" {
    value = azurerm_kubernetes_cluster.aks_cluster.id
    description = "The ID of the Azure Kubernetes Cluster"
}