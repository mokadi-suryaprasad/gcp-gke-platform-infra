variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "auto_create_subnetworks" {
  description = "Whether to automatically create subnetworks."
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "The network routing mode."
  type        = string
  default     = "GLOBAL"
}

variable "subnets" {
  description = "List of subnets for the VPC network."
  type = list(object({
    subnet_name           = string
    subnet_region         = string
    subnet_ip             = string
    subnet_private_access = optional(bool, false)
  }))
  default = []
}

variable "secondary_ranges" {
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
}

variable "region" {
  type    = string
  default = "us-central1"
}


variable "rules" {
  description = "List of firewall rules for the VPC network."
  type = list(object({
    rule_name    = string
    direction    = string
    priority     = number
    action       = string
    ports        = optional(list(string), [])
    source_ranges = optional(list(string), [])
    target_tags   = optional(list(string), [])
  }))
  default = []
}

variable "ingress_rules" {
  type = list(any)
  default = []
}

variable "egress_rules" {
  type = list(any)
  default = []
}

variable "cluster_location" {
  description = "The location (zone or region) for the GKE cluster."
  type        = string
  default     = "us-central1-a"
}
variable "node_pools" {
  description = "List of node pools for the GKE cluster."
  type = list(object({
    initial_count = number
    machine_type  = string
    min_count    = number
    max_count    = number
    disk_size_gb = number
  }))
  default = []
}