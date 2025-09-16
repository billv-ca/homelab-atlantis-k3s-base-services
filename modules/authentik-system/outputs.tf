output "authentik_api_key" {
  sensitive = true
  value = random_password.authentik_api_key.result
}
