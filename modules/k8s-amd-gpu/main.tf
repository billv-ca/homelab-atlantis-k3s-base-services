resource "helm_release" "k8s-device-plugin" {
  repository = "https://rocm.github.io/k8s-device-plugin/"
  chart = "amd-gpu"
  version = "0.20.0"
  create_namespace = true
  name = "amd-gpu"

  set = [{
    name = "nfd.enabled"
    value = true
  }]
}