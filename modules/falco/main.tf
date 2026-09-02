data "aws_ssm_parameter" "smtp" {
  name = "zoho-smtp-creds"
}

resource "helm_release" "falco" {
  name             = "falco"
  repository       = "https://falcosecurity.github.io/charts"
  chart            = "falco"
  version          = "9.1.0"
  namespace        = "falco"
  create_namespace = true

  set_sensitive = [
    {
      name  = "falcosidekick.config.smtp.password"
      value = data.aws_ssm_parameter.smtp.value
    },
  ]
  values = [
    <<-EOF
falcosidekick:
    enabled: true
    webui:
        enabled: true
        disableauth: true
    config:
        smtp:
            hostport: "smtp.zoho.com:587"
            tls: true
            authmechanism: "plain"
            user: "bill@vandenberk.me"
            from: "bill@vandenberk.me"
            to: "bill@vandenberk.me"
            outputformat: "html"
            minimumpriority: "critical"
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
