# homelab-atlantis-k3s-base-services
This repo exists as part of the billv-ca/homelab-* series of repositories containing IaC and documentation for my homelab. See [homelab-documentation](https://github.com/billv-ca/homelab-documentation) for more information.

This repo contains parts of the homelab running in Kubernetes that I consider `base-services` generally these are resources that need to be in place before the next set of services can be applied

## Usage
This repo (once applied initially manually) is managed by Atlantis and upgraded automatically by renovatebot. To manually apply changes, read on.

### Manual usage
#### Prerequisites
Credentials must be in place for `Kubernetes` and `AWS` in your environment. Additionally there must be an environment variable set before you can run terraform.

|Variable|Purpose|
|--------|-------|
|KUBE_CONFIG_PATH|Tells the Kubernetes provider where to find your kubectl config, should probably be `~/.kube/config`|

This variable can automatically be added to your environment by running `source setup_env.sh`

#### Terraform
To apply the terraform, once the pre-requesites are met, simply run the following
```sh
terraform init
terraform plan #to preview changes (optional, apply will be interactive anyway)
terraform apply
```
