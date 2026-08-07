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
    tag: "v3.4.1"
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
#        http:
#            middlewares:
#                cors:
#                    headers:
#                      accessControlAllowMethods:
#                        - GET
#                      accessControlAllowCredentials: true
#                      accessControlAllowOriginListRegex:
#                        - "https:\\/\\/.*\\.billv\\.ca"
#                      accessControlMaxAge: 300
logs:
    access:
        enabled: true

#ingressRoute:
#  dashboard:
#    enabled: true
#    matchRule: Host(`traefik.billv.ca`)
#    services:
#      - name: api@internal
#        kind: TraefikService
#    entryPoints: ["websecure"]
#    middlewares: ["authentik@kube-system"]
EOF
         }
    }
}
