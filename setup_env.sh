#!/usr/bin/env bash
AUTHENTIK_KEY=$(aws ssm get-parameter --name authentik-api-key --with-decryption | jq .Parameter.Value -r)
export TF_VAR_authentik_api_key="${AUTHENTIK_KEY}"
export KUBE_CONFIG_PATH=~/.kube/config