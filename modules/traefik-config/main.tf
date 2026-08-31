resource "kubernetes_manifest" "traefik_entrypoints" {
  field_manager {
    name           = "terraform"
    force_conflicts = true
  }
    manifest = {
        "apiVersion" = "helm.cattle.io/v1"
        "kind" = "HelmChartConfig"
        "metadata" = {
            "name" = "traefik"
            "namespace" = "kube-system"
         }
         "spec" = {
            "valuesContent" = <<-EOF
deployment:
    podAnnotations:
    prometheus.io/port: "8082"
    prometheus.io/scrape: "true"
providers:
    kubernetesIngress:
        publishedService:
            enabled: true
priorityClassName: "system-cluster-critical"
image:
    repository: "traefik"
    tag: "v3.3.6"
tolerations:
    - key: "CriticalAddonsOnly"
      operator: "Exists"
    - key: "node-role.kubernetes.io/control-plane"
      operator: "Exists"
      effect: "NoSchedule"
    - key: "node-role.kubernetes.io/master"
      operator: "Exists"
      effect: "NoSchedule"
service:
    ipFamilyPolicy: "PreferDualStack"
ports:
    websecure:
        forwardedHeaders:
            trustedIPs:
                - 10.0.0.0/8
        middlewares:
          - kube-system-cors@kubernetescrd
logs:
    access:
        enabled: true
experimental:
  plugins:
    traefik-modsecurity-plugin:
      moduleName: "github.com/madebymode/traefik-modsecurity-plugin"
      version: "v1.6.0"
EOF
         }
    }
}

resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "dashboard"
      "namespace" = "kube-system"
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind"  = "Rule"
        "match" = "Host(`traefik.billv.ca`)"
        "middlewares" = [{
          "name"      = "authentik"
          "namespace" = "kube-system"
        }]
        "services" = [{
          "kind" = "TraefikService"
          "name" = "api@internal"
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "cors_middleware" {
  field_manager {
    name           = "terraform"
    force_conflicts = true
  }
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "cors"
      "namespace" = "kube-system"
    }
    "spec" = {
      "headers" = {
        "accessControlAllowMethods": ["GET", "OPTIONS"]
        "accessControlAllowOriginListRegex": ["https:\\/\\/auth\\.billv\\.ca", "https:\\/\\/.*\\.billv\\.ca"]
        "accessControlMaxAge": "300"
        "addVaryHeader": "true"
        "accessControlAllowCredentials": "true"
      }
    }
  }
}

resource "kubernetes_manifest" "waf" {
  field_manager {
    name           = "terraform"
    force_conflicts = true
  }
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = "waf"
      "namespace" = "kube-system"
    }
    "spec" = {
      "plugin" = {
        "traefik-modsecurity-plugin" = {
            "BadRequestsThresholdCount" = "25"
            "BadRequestsThresholdPeriodSecs" = "600"
            "JailEnabled" = "true"
            "JailTimeDurationSecs" = "600"
            "ModsecurityUrl" = "http://owasp-modsecurity-crs.kube-system.svc.cluster.local:80"
            "TimeoutMillis" = "2000"
        }
      }
    }
  }
}
