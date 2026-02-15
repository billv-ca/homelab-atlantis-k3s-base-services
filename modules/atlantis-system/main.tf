terraform {
  required_providers {
    kubernetes = {
        source = "hashicorp/kubernetes"
    }
    helm = {
        source = "hashicorp/helm"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = "atlantis-system"
  }
}

resource "kubernetes_cluster_role_binding_v1" "atlantis-admin" {
  metadata {
    name = "atlantis-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "runatlantis"
    namespace = "atlantis-system"
  }
}

data "aws_ssm_parameter" "atlantis-key" {
  name = "/runatlantis/key"
}

data "aws_ssm_parameter" "atlantis-secret" {
  name = "/runatlantis/webhook-secret"
}

data "aws_ssm_parameter" "proxmox-password" {
  name = "proxmox-ve-password"
}

resource "aws_iam_user" "atlantis" {
  path = "/system/"
  name = "atlantis"
}

resource "aws_iam_user_policy" "atlantis" {
  name = "atlantis"
  user = aws_iam_user.atlantis.name
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GrantAtlantisS3Access",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:Get*",
        "s3:ListBucket",
        "s3:DeleteObject",
      ],
      "Resource": [
        "arn:aws:s3:::tfstate.billv.ca",
        "arn:aws:s3:::tfstate.billv.ca/*",
        "arn:aws:s3:::longhorn-backups.billv.ca",
        "arn:aws:s3:::longhorn-backups.billv.ca/*"
      ]
    },
    {
      "Sid": "GrantAtlantisSSMAccess",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter*",
        "ssm:ListTagsForResource"
      ],
      "Resource": [
        "arn:aws:ssm:us-east-1:398183381961:parameter/runatlantis/webhook-secret",
        "arn:aws:ssm:us-east-1:398183381961:parameter/authentik-api-key",
        "arn:aws:ssm:us-east-1:398183381961:parameter/zoho-smtp-creds",
        "arn:aws:ssm:us-east-1:398183381961:parameter/proxmox-ve-password",
        "arn:aws:ssm:us-east-1:398183381961:parameter/runatlantis/key"
      ]
    },
    {
      "Sid": "AtlantisSSMDescribeStar",
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters",
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "GrantAtlantisIAMAccess",
      "Effect": "Allow",
      "Action": [
        "iam:GetUser",
        "iam:GetUserPolicy",
        "iam:ListAccessKeys",
        "iam:GetSAMLProvider",
        "iam:ListPolicies",
        "iam:GetPolicy",
        "iam:GetRole",
        "iam:ListRolePolicies",
        "iam:GetPolicyVersion",
        "iam:ListAttachedRolePolicies"
      ],
      "Resource": [
        "arn:aws:iam::398183381961:user/system/*",
        "arn:aws:iam::398183381961:saml-provider/Authentik3s",
        "arn:aws:iam::398183381961:role/Authentik-SAML-Admin",
        "arn:aws:iam::*:policy/*"
      ]
    },
    {
      "Sid": "GrantAtlantisRoute53Access",
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "GrantAtlantisRoute53HostedZoneAccess",
      "Effect": "Allow",
      "Action": [
        "route53:GetHostedZone",
        "route53:ListTagsForResource",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/Z0798217GFK6DVLPWL4O"
      ]
    }
  ]})
}

resource "aws_iam_access_key" "atlantis" {
  user = aws_iam_user.atlantis.name
}

resource "kubernetes_secret_v1" "authentik_api_key" {
  metadata {
    name = "authentik-api-key"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    authentik_api_key = var.authentik_api_key
  }
}

resource "kubernetes_secret_v1" "proxmox_password" {
  metadata {
    name = "proxmox-password"
    namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  }

  data = {
    proxmox_password = data.aws_ssm_parameter.proxmox-password.value
  }
}

resource "helm_release" "atlantis" {
  name = "runatlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  chart = "atlantis"
  version = "5.28.0"
  namespace = kubernetes_namespace_v1.namespace.metadata[0].name
  create_namespace = false

  set = [
    {
    name = "extraArgs[0]"
    value = "--automerge"
  },
  {
    name = "environment.ATLANTIS_GH_ORG"
    value = "billv-ca"
  },
  {
    name = "environment.ATLANTIS_GH_TEAM_ALLOWLIST"
    value = "admins:plan\\, admins:apply\\, admins:state\\, admins:import\\, admins:unlock\\, admins:approve_policies"
  },
  {
    name = "environment.ATLANTIS_EMOJI_REACTION"
    value = "rocket"
  },
  {
    name = "environmentSecrets[0].name"
    value = "TF_VAR_authentik_api_key"
  },
  {
    name = "environmentSecrets[0].secretKeyRef.name"
    value = "authentik-api-key"
  },
  {
    name = "environmentSecrets[0].secretKeyRef.key"
    value = "authentik_api_key"
  },
  {
    name = "environmentSecrets[1].name"
    value = "TF_VAR_proxmox_password"
  },
  {
    name = "environmentSecrets[1].secretKeyRef.name"
    value = kubernetes_secret_v1.proxmox_password.metadata[0].name
  },
  {
    name = "environmentSecrets[1].secretKeyRef.key"
    value = "proxmox_password"
  },
  {
    name = "atlantisUrl"
    value = "https://atlantis.billv.ca"
  },
  {
    name = "githubApp.id"
    value = "1224527"
    type = "string"
  },
  {
    name = "volumeClaim.storageClassName"
    value = "longhorn"
  },
  {
    name = "orgAllowlist"
    value = "github.com/billv-ca/homelab-atlantis*"
  }
]

  set_sensitive = [{
    name = "githubApp.key"
    value = data.aws_ssm_parameter.atlantis-key.value
  },
  {
    name = "githubApp.secret"
    value = data.aws_ssm_parameter.atlantis-secret.value
  },
  {
    name = "aws.credentials"
    value = <<EOF
[default]
aws_access_key_id=${aws_iam_access_key.atlantis.id}
aws_secret_access_key=${aws_iam_access_key.atlantis.secret}
region=us-east-1
EOF
  }]
}

resource "kubernetes_manifest" "certificate_authentik_star_billv_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "atlantis-billv-ca"
      "namespace" = kubernetes_namespace_v1.namespace.metadata[0].name
    }
    "spec" = {
      "dnsNames" = [
        "atlantis.billv.ca",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt"
      }
      "secretName" = "atlantis-billv-ca"
    }
  }
}

resource "kubernetes_manifest" "ingressroute" {
  manifest = {
    "apiVersion" = "traefik.io/v1alpha1"
    "kind" = "IngressRoute"
    "metadata" = {
      "name" = "atlantis"
      "namespace" = kubernetes_namespace_v1.namespace.metadata[0].name
    }
    "spec" = {
      "entryPoints" = ["websecure"]
      "routes" = [
      {
        "kind" = "Rule"
        "match" = "Host(`atlantis.billv.ca`) && !(Path(`/events`) && Method(`POST`))"
        "middlewares" = [{
          "name" = "authentik"
          "namespace" = kubernetes_namespace_v1.namespace.metadata[0].name
        }],
        "services" = [{
          "kind" = "Service"
          "name" = "runatlantis"
          "port" = 80
        }]
      },
      {
        "kind" = "Rule"
        "match" = "Host(`atlantis.billv.ca`) && Path(`/events`) && Method(`POST`)"
        "services" = [{
          "kind" = "Service"
          "name" = "runatlantis"
          "port" = 80
        }]
      }]
      "tls" = {
        "secretName" = "atlantis-billv-ca"
      }
    }
  }
}
