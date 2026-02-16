output "network_name" {
  value = module.vpc_network.network_name
}

output "network_self_link" {
  value = module.vpc_network.network_self_link
}

output "subnets" {
  value = module.vpc_subnets.subnets
}

output "subnet_names" {
  value = [for s in module.vpc_subnets.subnets : s.name]
}

# Cluster outputs
output "cluster_name" {
  value = module.cluster_1.name
}

output "cluster_location" {
  value = module.cluster_1.location
}

# Nodepool outputs (Fabric style)
output "node_pool_name" {
  value = module.node_pool_default.name
}
