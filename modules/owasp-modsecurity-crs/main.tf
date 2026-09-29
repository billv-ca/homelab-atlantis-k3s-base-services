resource "kubernetes_config_map_v1" "exclusion_rules" {
  metadata {
    name      = "modsecurity-exclusion-rules"
    namespace = "kube-system"
  }
  data = {
    "RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf" = <<EOF
# Trilium Notes
SecRuleUpdateTargetById 932235 "!ARGS:json.content"
SecRuleUpdateTargetById 941100 "!ARGS:json.content"
SecRuleUpdateTargetById 941160 "!ARGS:json.content"
SecRuleUpdateTargetById 932380 "!ARGS:json.content"
SecRuleUpdateTargetById 942550 "!ARGS:json.content"
SecRuleUpdateTargetById 949110 "!ARGS:json.content"

# OCIS
SecRuleUpdateTargetById 942290 "!ARGS_NAMES:$expand"
SecRuleUpdateTargetById 942290 "!ARGS_NAMES:$filter"
SecRuleUpdateTargetById 942290 "!ARGS_NAMES:$orderby"
EOF
  "REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf" = <<EOF
# OCIS
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq ocis.billv.ca" "id:100130,phase:1,pass,nolog,ctl:ruleRemoveById=930130"

#Open WebUI
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq ai.billv.ca" "id:100131,phase:1,pass,nolog,ctl:ruleRemoveById=943110"

#Atlantis
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100132,phase:1,pass,nolog,ctl:ruleRemoveById=930120
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100133,phase:1,pass,nolog,ctl:ruleRemoveById=932235
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100134,phase:1,pass,nolog,ctl:ruleRemoveById=932140
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100135,phase:1,pass,nolog,ctl:ruleRemoveById=932230
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100136,phase:1,pass,nolog,ctl:ruleRemoveById=932250
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100137,phase:1,pass,nolog,ctl:ruleRemoveById=932370
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100138,phase:1,pass,nolog,ctl:ruleRemoveById=941100
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100139,phase:1,pass,nolog,ctl:ruleRemoveById=941160
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100140,phase:1,pass,nolog,ctl:ruleRemoveById=941180
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100141,phase:1,pass,nolog,ctl:ruleRemoveById=941190
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100142,phase:1,pass,nolog,ctl:ruleRemoveById=941370
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100143,phase:1,pass,nolog,ctl:ruleRemoveById=941390
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100144,phase:1,pass,nolog,ctl:ruleRemoveById=941400
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100145,phase:1,pass,nolog,ctl:ruleRemoveById=942140
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100146,phase:1,pass,nolog,ctl:ruleRemoveById=942151
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100147,phase:1,pass,nolog,ctl:ruleRemoveById=942190
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq atlantis.billv.ca" "id:100148,phase:1,pass,nolog,ctl:ruleRemoveById=942360

#Headlamp
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100149,phase:1,pass,nolog,ctl:ruleRemoveById=930120
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100150,phase:1,pass,nolog,ctl:ruleRemoveById=932235
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100151,phase:1,pass,nolog,ctl:ruleRemoveById=932140
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100152,phase:1,pass,nolog,ctl:ruleRemoveById=932230
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100153,phase:1,pass,nolog,ctl:ruleRemoveById=932250
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100154,phase:1,pass,nolog,ctl:ruleRemoveById=932370
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100155,phase:1,pass,nolog,ctl:ruleRemoveById=941100
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100156,phase:1,pass,nolog,ctl:ruleRemoveById=941160
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100157,phase:1,pass,nolog,ctl:ruleRemoveById=941180
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100158,phase:1,pass,nolog,ctl:ruleRemoveById=941190
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100159,phase:1,pass,nolog,ctl:ruleRemoveById=941370
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100160,phase:1,pass,nolog,ctl:ruleRemoveById=941390
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100161,phase:1,pass,nolog,ctl:ruleRemoveById=941400
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100162,phase:1,pass,nolog,ctl:ruleRemoveById=942140
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100163,phase:1,pass,nolog,ctl:ruleRemoveById=942151
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100164,phase:1,pass,nolog,ctl:ruleRemoveById=942190
SecRule REQUEST_HEADERS:X-Forwarded-Host "@streq kube.billv.ca" "id:100165,phase:1,pass,nolog,ctl:ruleRemoveById=942360
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
    replicas = 1

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

          volume_mount {
            name = "exclusion-rules"
            mount_path = "/etc/modsecurity.d/owasp-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf"
            sub_path = "REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf"
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
            value = "GET HEAD POST PUT DELETE OPTIONS PATCH COPY LOCK MKCOL MOVE UNLOCK PROPFIND PROPPATCH"
          }

          env {
            name = "ALLOWED_REQUEST_CONTENT_TYPE"
            value = "|application/x-www-form-urlencoded| |multipart/form-data| |multipart/related| |text/xml| |application/xml| |application/soap+xml| |application/json| |application/cloudevents+json| |application/cloudevents-batch+json| |application/offset+octet-stream| |application/json-patch+json|"
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
    replicas = 1

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
