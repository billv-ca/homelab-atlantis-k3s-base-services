resource "helm_release" "falco" {
  name             = "falco"
  repository       = "https://falcosecurity.github.io/charts"
  chart            = "falco"
  version          = "9.1.0"
  namespace        = "falco"
  create_namespace = true

  set = [
    {
      name  = "falcosidekick.enabled"
      value = "true"
    },
    {
      name  = "falcosidekick.webui.enabled"
      value = "true"
    },
    {
      name  = "falcosidekick.webui.disableauth"
      value = "true"
    }
  ]
}


resource "kubernetes_manifest" "certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "falco-billv-ca"
      "namespace" = "falco"
    }
    "spec" = {
      "dnsNames" = [
        "lfalcoonghorn.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "falco-billv-ca"
    }
  }
}

resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "name"      = "falco"
      "namespace" = "falco"
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [{
        "kind"  = "Rule"
        "match" = "Host(`falco.billv.ca`)"
        "middlewares" = [{
          "name"      = "authentik"
          "namespace" = "falco"
        }]
        "services" = [{
          "kind" = "Service"
          "name" = "falco-falcosidekick-ui"
          "port" = 2802
        }]
      }]
      "tls" = {
        "secretName" = "falco-billv-ca"
      }
    }
  }
}
