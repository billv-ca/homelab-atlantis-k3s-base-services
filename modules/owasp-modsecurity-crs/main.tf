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
      }

      spec {
        container {
          name  = "modsecurity-crs"
          image = "owasp/modsecurity-crs:4.25-nginx-lts"

          port {
            container_port = 8080
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
