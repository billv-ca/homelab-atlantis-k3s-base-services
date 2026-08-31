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

          env {
            name = "BACKEND"
            value = "http://dummy.kube-system.svc.cluster.local"
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
}

