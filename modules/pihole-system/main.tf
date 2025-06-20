terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
    helm = {
        source = "hashicorp/helm"
    }
  }
}

data "kubernetes_service_v1" "traefik" {
  metadata {
    name = "traefik"
    namespace = "kube-system"
  }
}

resource "helm_release" "pihole" {
  name = "pihole"
  repository = "https://mojo2600.github.io/pihole-kubernetes/"
  chart = "pihole"
  version = "2.31.0"
  namespace = "pihole-system"
  create_namespace = true
  values = [
<<-EOF
admin:
  enabled: false

podDisruptionBudget:
  enabled: true
  minAvailable: 1

replicaCount: 2
serviceWeb:
  https:
    enabled: false

serviceDns:
  type: LoadBalancer
  annotations:
    metallb.universe.tf/loadBalancerIPs: 10.206.101.1
    metallb.universe.tf/allow-shared-ip: pihole-svc

serviceDhcp:
  enabled: false

persistentVolumeClaim:
  enabled: false
#  storageClass: longhorn

maxUnavailable: 1

# enables cloudflare tunnel sidecar container
# and sets upstream dns in pihole to leverage it
doh:
  enabled: true
  pullPolicy: IfNotPresent
  envVars: {
    DOH_UPSTREAM: "https://1.1.1.1/dns-query"
  }

dnsmasq:
  customSettings:
    - except-interface=nonexisting

image:
  repository: "pihole/pihole"
  tag: "2025.06.2"
EOF
  ]
}

resource "kubernetes_manifest" "certificate_authentik_star_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "pihole-billv-ca"
      "namespace" = "pihole-system"
    }
    "spec" = {
      "dnsNames" = [
        "pihole.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "pihole-billv-ca"
    }
  }
}

resource "kubernetes_manifest" "middleware_admin" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "Middleware"
    "metadata" = {
      "name" = "add-admin"
      "namespace" = "pihole-system"
    }
    "spec" = {
      "addPrefix" = {
        "prefix" = "/admin"
      }
    }
  }
}

resource "kubernetes_manifest" "middleware_ipallowlist" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "Middleware"
    "metadata" = {
      "name" = "allowlist"
      "namespace" = "pihole-system"
    }
    "spec" = {
      "ipAllowList" = {
        "ipStrategy" = {
          "depth" = 1
        }
        "sourceRange" = [
          "10.206.2.7/32"
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "pihole"
      "namespace" = "pihole-system"
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`pihole.billv.ca`)"
        "middlewares" = [{
          "name" = "authentik"
          "namespace" = "pihole-system"
        # },{
        #   "name" = "add-admin"
        #   "namespace" = "pihole-system"
        }]
        "services" = [{
          "kind" = "Service"
          "name" = "pihole-web"
          "port" = 80
        }]
      }]
      "tls" = {
        "secretName" = "pihole-billv-ca"
      }
    }
  }
}

resource "kubernetes_manifest" "certificate_piholeassistant_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "piholeassistant-billv-ca"
      "namespace" = "pihole-system"
    }
    "spec" = {
      "dnsNames" = [
        "piholeassistant.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "piholeassistant-billv-ca"
    }
  }
}

resource "kubernetes_manifest" "assistant_ingressroute" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "piholeassistant"
      "namespace" = "pihole-system"
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind" = "Rule"
        "match" = "Host(`piholeassistant.billv.ca`)"
        "middlewares" = [{
          "name" = "allowlist"
          "namespace" = "pihole-system"
        }]
        "services" = [{
          "kind" = "Service"
          "name" = "pihole-web"
          "port" = 80
        }]
      }]
      "tls" = {
        "secretName" = "piholeassistant-billv-ca"
      }
    }
  }
}
