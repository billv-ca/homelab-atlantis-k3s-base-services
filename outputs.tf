output "authentik_api_key" {
    sensitive = true
    value = module.authentik_system.authentik_api_key
}