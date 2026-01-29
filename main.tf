terraform {
  backend "s3" {
    bucket = "tfstate.billv.ca"
    key = "k8s-setup/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "kubernetes" {
    ignore_annotations = [
      "metallb\\.universe\\.tf\\/ip\\-allocated\\-from\\-pool",
      "kubectl\\.kubernetes\\.io\\/restartedAt"
    ]
}

provider "helm" {
  kubernetes = {}
}

provider "aws" {
  region = "us-east-1"
}

module "k8s_amd_gpu" {
  source = "./modules/k8s-amd-gpu"
}

module "metallb-system" {
  source = "./modules/metallb-system"
}

module "cert-manager" {
  source = "./modules/cert-manager"
}

module "authentik_system" {
  source = "./modules/authentik-system"
}

module "longhorn_system" {
  source = "./modules/longhorn-system"
}

module "pihole_system" {
  source = "./modules/pihole-system"
}

module "omada_controller" {
  source = "./modules/omada-controller"
}

module "atlantis" {
  source = "./modules/atlantis-system"
  authentik_api_key = module.authentik_system.authentik_api_key
}

module "traefik_config" {
  source = "./modules/traefik-config"
}

resource "kubernetes_service_account_v1" "bill" {
  metadata {
    name = "bill"
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "bill"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account_v1.bill.metadata.0.name
  }
}

resource "kubernetes_secret_v1" "bill_token" {
  metadata {
    name = "bill-token"
    annotations = {
      "kubernetes.io/service-account.name": "bill"
    }
  }
  type = "kubernetes.io/service-account-token"
}
