# 🚀 GCP GKE Platform Infrastructure (OpenTofu / Terraform)

This repository contains Infrastructure as Code (IaC) for deploying a **production-ready Google Kubernetes Engine (GKE) platform** on Google Cloud using **OpenTofu / Terraform**.

It provisions:

- VPC networking
- Subnets with secondary IP ranges
- Firewall rules
- Cloud NAT for private node internet access
- Private GKE Standard cluster
- Managed node pools
- Secure networking defaults

---

## 📦 Architecture Overview

```
┌──────────────────────────────────────────┐
│               Google Cloud               │
│                                          │
│  VPC Network                             │
│   ├── Subnet (Primary range)             │
│   ├── Pod Secondary Range                │
│   ├── Service Secondary Range            │
│   └── Cloud Router + Cloud NAT           │
│                                          │
│  Private GKE Cluster (Standard)          │
│   ├── Private Nodes                      │
│   ├── Workload Identity                  │
│   ├── Dataplane v2                       │
│   └── Node Pool(s)                       │
└──────────────────────────────────────────┘
```

---

## 🧱 Modules Used

### Terraform Google Modules

- terraform-google-network
- terraform-google-cloud-nat

### Cloud Foundation Fabric Modules

- gke-cluster-standard
- gke-nodepool

---

## 📂 Repository Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── dev.tfvars
├── versions.tf
├── providers.tf
└── README.md
```

---

## ⚙️ Prerequisites

- OpenTofu or Terraform installed
- Google Cloud SDK installed
- Authenticated with GCP:

```bash
gcloud auth application-default login
```

- Required APIs enabled:

```bash
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com
```

---

## 🚀 Deployment Steps

### 1️⃣ Initialize

```bash
tofu init
```

### 2️⃣ Validate

```bash
tofu validate
```

### 3️⃣ Plan

```bash
tofu plan -var-file="dev.tfvars"
```

### 4️⃣ Apply

```bash
tofu apply -var-file="dev.tfvars"
```

---

## 🔐 Security Features

- Private GKE nodes
- Authorized control plane access
- Workload Identity enabled
- VPC-native cluster networking
- Optional deletion protection
- Cloud NAT for outbound access without public IPs

---

## 🌐 Networking

The setup includes:

- Custom VPC
- Custom subnets
- Secondary ranges for:
  - Pods
  - Services
- Cloud NAT for internet egress from private nodes

---

## 📊 Cluster Features

- GKE Standard mode
- Dataplane v2 enabled
- Managed Prometheus
- Node auto-scaling
- Separate node pool module
- Upgrade-safe modular design

---

## 🧩 Customization

Update values inside:

```
dev.tfvars
```

Examples:

- Cluster location
- Machine type
- Node count
- CIDR ranges
- Firewall rules

---

## 🧹 Destroy Infrastructure

```bash
tofu destroy -var-file="dev.tfvars"
```

⚠️ Ensure `deletion_protection = false` before destroy.

---

## 🛡️ Git Ignore (Recommended)

```
.terraform/
*.tfstate
*.tfstate.*
crash.log
*.tfvars
.terraform.lock.hcl
```

---

## 📚 Learning Goals

This repository demonstrates:

- Production-style GKE provisioning
- Modular infrastructure design
- Cloud networking best practices
- OpenTofu-compatible infrastructure workflows

---

## 🤝 Contributions

Feel free to fork, improve, and open pull requests.

---

## 👨‍💻 Author

**Surya Prasad**  
Cloud & DevOps Engineer  
Focused on GCP, Kubernetes, DevSecOps, and Platform Engineering.
