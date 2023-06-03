output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.cluster.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.cluster.endpoint
  description = "GKE Cluster Host"
}

output "kubectl_connection_command" {
  value       = "gcloud container clusters get-credentials ${google_container_cluster.cluster.name} --region ${var.region}"
  description = "Connection command"
}

