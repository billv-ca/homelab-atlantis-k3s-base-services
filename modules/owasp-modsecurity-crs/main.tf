resource "kubernetes_config_map_v1" "exclusion_rules" {
  metadata {
    name      = "modsecurity-exclusion-rules"
    namespace = "kube-system"
  }
  data = {
    "RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf" = <<EOF
SecRuleUpdateTargetById 932235 "!ARGS:json.content"
SecRuleUpdateTargetById 941100 "!ARGS:json.content"
SecRuleUpdateTargetById 941160 "!ARGS:json.content"
EOF
  }
}

resource "kubernetes_deployment_v1" "owasp_modsecurity_crs" {
  metadata {
    name      = "owasp-modsecurity-crs"
    namespace = "kube-system"
    labels = {
      app = "owasp-modsecurity-crs"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "owasp-modsecurity-crs"
      }
    }

    template {
      metadata {
        labels = {
          app = "owasp-modsecurity-crs"
        }
        annotations = {
          # This hash changes when the configmap data changes, triggering a rolling update
          config_hash = md5(jsonencode(kubernetes_config_map_v1.exclusion_rules.data))
        }
      }

      spec {
        volume {
          name = "exclusion-rules"
          config_map {
            name = "modsecurity-exclusion-rules"
          }
        }

        container {
          name  = "modsecurity-crs"
          image = "owasp/modsecurity-crs:4.25-nginx-lts"

          volume_mount {
            name = "exclusion-rules"
            mount_path = "/etc/modsecurity.d/owasp-crs/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf"
            sub_path = "RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf"
          }

          port {
            container_port = 8080
          }

          env {
            name = "BACKEND"
            value = "http://whoami.kube-system.svc.cluster.local"
          }

          env {
            name = "ALLOWED_METHODS"
            value = "GET HEAD POST PUT DELETE OPTIONS PROPFIND"
          }

          env {
            name = "MODSEC_RULE_ENGINE"
            value = "On"
          }

          env {
            name = "MODSEC_REQ_BODY_ACCESS"
            value = "On"
          }

          env {
            name = "MODSEC_RESP_BODY_ACCESS"
            value = "On"
          }

          image_pull_policy = "IfNotPresent"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "owasp_modsecurity_crs" {
  metadata {
    name      = "owasp-modsecurity-crs"
    namespace = "kube-system"
    labels = {
      app = "owasp-modsecurity-crs"
    }
  }

  spec {
    selector = {
      app = "owasp-modsecurity-crs"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment_v1" "whoami" {
  metadata {
    name      = "whoami"
    namespace = "kube-system"
    labels = {
      app = "whoami"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "whoami"
      }
    }

    template {
      metadata {
        labels = {
          app = "whoami"
        }
      }

      spec {
        container {
          name  = "whoami"
          image = "traefik/whoami"

          port {
            container_port = 80
          }

          image_pull_policy = "IfNotPresent"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "whoami" {
  metadata {
    name      = "whoami"
    namespace = "kube-system"
    labels = {
      app = "whoami"
    }
  }

  spec {
    selector = {
      app = "whoami"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
