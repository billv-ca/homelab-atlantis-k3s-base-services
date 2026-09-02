resource "helm_release" "falco" {
  name             = "falco"
  repository       = "https://falcosecurity.github.io/charts"
  chart            = "falco"
  version          = "9.1.0"
  namespace        = "falco"
  create_namespace = true

  values = [
    <<-EOF
falcosidekick:
    enabled: true
    webui:
        enabled: true
        disableauth: true
falco:
    customRules:
        overrides.yaml: |-
            - macro: user_known_contact_k8s_api_server_activities
            condition: (k8s.ns.name in ("monitoring", "atlantis-system", "authentik"))

            - list: trusted_images
            items: ["docker.io/pihole/pihole"]
EOF
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
