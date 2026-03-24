resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = "metallb-system"
    labels = {
        "pod-security.kubernetes.io/audit" = "privileged"
        "pod-security.kubernetes.io/enforce" = "privileged"
        "pod-security.kubernetes.io/warn" = "privileged"
    }
  }
}

resource "helm_release" "metallb" {
  repository = "https://metallb.github.io/metallb"
  chart = "metallb"
  version = "0.15.3"
  create_namespace = false
  namespace = "metallb-system"
  name = "metallb"

  set = [{
    name = "speaker.frr.enabled"
    value = true
  }]
}