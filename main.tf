locals {
  resource_name = "vpc-network"

  # Base module repo
  module_source = "git::https://github.com/terraform-google-modules/terraform-google-network.git"
  cloud_nat_module_source = "git::https://github.com/terraform-google-modules/terraform-google-cloud-nat.git?ref=v6.0.0"
  # Cloud Foundation Fabric modules
  gke_standard_module_source   = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-cluster-standard?ref=v52.1.0"
  gke_node_pools_module_source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-nodepool?ref=v52.1.0"

  module_version = "v15.0.0"
}

# ---------------------------------------------------
# VPC NETWORK
# ---------------------------------------------------
module "vpc_network" {
  source = "${local.module_source}//modules/vpc?ref=${local.module_version}"

  project_id              = var.project_id
  network_name            = "${local.resource_name}-main"
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
  description             = "VPC network for ${local.resource_name}-main"
}

# ---------------------------------------------------
# SUBNETS
# ---------------------------------------------------
module "vpc_subnets" {
  source = "${local.module_source}//modules/subnets?ref=${local.module_version}"

  project_id   = var.project_id
  network_name = module.vpc_network.network_name
  subnets      = var.subnets
  secondary_ranges = var.secondary_ranges
}

# ---------------------------------------------------
# CLOUD NAT
# ---------------------------------------------------

module "cloud_nat" {
  source = local.cloud_nat_module_source

  project_id = var.project_id
  region     = var.region

  # Let module create router automatically
  create_router = true
  router        = "${local.resource_name}-router"
  network       = module.vpc_network.network_self_link

  name = "${local.resource_name}-nat"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetworks = [
    for s in values(module.vpc_subnets.subnets) : {
      name                    = s.self_link
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
      secondary_ip_range_names = [
        "pods",
        "services"
      ]
    }
  ]

  log_config_enable = true
  log_config_filter = "ERRORS_ONLY"
}


# ---------------------------------------------------
# FIREWALL RULES
# ---------------------------------------------------
module "vpc_firewall" {
  source = "${local.module_source}//modules/firewall-rules?ref=${local.module_version}"

  project_id   = var.project_id
  network_name = module.vpc_network.network_name

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}

# ---------------------------------------------------
# GKE CLUSTER (FABRIC)
# ---------------------------------------------------
module "cluster_1" {
  source     = local.gke_standard_module_source
  project_id = var.project_id
  name       = "${local.resource_name}-gke-cluster"
  location   = var.cluster_location
  deletion_protection = false
  
access_config = {
  private_nodes = true

  ip_access = {
    disable_public_endpoint = false

    authorized_ranges = {
      internal-vms = "10.0.0.0/8"
    }
  }

  master_ipv4_cidr_block = "172.16.0.0/28"
}

  vpc_config = {
    network    = module.vpc_network.network_self_link
    subnetwork = values(module.vpc_subnets.subnets)[0].self_link

    secondary_range_names = {
      pods     = "pods"
      services = "services"
    }
  }

  labels = {
    environment = "dev"
  }
}

# ---------------------------------------------------
# GKE NODE POOL (FABRIC)
# ---------------------------------------------------
module "node_pool_default" {
  source     = local.gke_node_pools_module_source
  project_id = var.project_id

  cluster_name = module.cluster_1.name
  location     = module.cluster_1.location
  name         = "${local.resource_name}-default-node-pool"

  node_count = {
    initial = var.node_pools[0].initial_count
  }

  nodepool_config = {
    autoscaling = {
      min_node_count = var.node_pools[0].min_count
      max_node_count = var.node_pools[0].max_count
    }
  }

  node_config = {
    machine_type = var.node_pools[0].machine_type
    disk_size_gb = var.node_pools[0].disk_size_gb
  }
}
