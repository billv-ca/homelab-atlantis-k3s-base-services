resource "helm_release" "intel-device-plugins-operator" {
  repository = "https://intel.github.io/helm-charts"
  chart = "intel-device-plugins-operator"
  version = "0.36.0"
  create_namespace = true
  name = "intel-device-operator"
}

resource "helm_release" "intel-device-plugins-gpu" {
  depends_on = [ helm_release.intel-device-plugins-operator ]
  repository = "https://intel.github.io/helm-charts"
  chart = "intel-device-plugins-gpu"
  version = "0.36.0"
  create_namespace = true
  name = "intel-gpu"
}
