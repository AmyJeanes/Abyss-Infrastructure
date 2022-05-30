variable "kubernetes_version" {
  sensitive = false
}

variable "ssh_public_key" {
  sensitive = true
}

variable "cloudflare_api_token" {
  sensitive = true
}

variable "cloudflare_zone_id" {
  sensitive = true
}

variable "home_ip" {
  sensitive = true
}

variable "mariadb_root_password" {
  sensitive = true
}

variable "email" {
  sensitive = true
}

variable "host" {
  sensitive = true
}

variable "aks_login" {
  type = bool
}

variable "oauth2_client_id" {
  sensitive = true
}

variable "oauth2_client_secret" {
  sensitive = true
}

variable "oauth2_cookie_secret" {
  sensitive = true
}
