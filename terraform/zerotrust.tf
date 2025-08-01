resource "cloudflare_zero_trust_access_policy" "access_tokens" {
  account_id = var.cloudflare_account_id
  name       = "Access tokens"
  decision   = "non_identity"
  include = [{
    any_valid_service_token = {}
  }]
}

resource "cloudflare_zero_trust_access_policy" "allowed_users" {
  account_id = var.cloudflare_account_id
  name       = "Allowed users"
  decision   = "allow"
  include = [{
    email = {
      email = var.email
    }
  }]
}
locals {
  zero_trust_applications = {
    "hello-world-zero-trust" = {
      name    = "Hello World"
      service = "http://hello-world",
      secure  = false
    }
    "kubernetes-api" = {
      name    = "Kubernetes API"
      service = "tcp://kubernetes:443"
      secure  = true
    }
    "kubernetes-dashboard" = {
      name          = "Kubernetes Dashboard"
      service       = "https://kubernetes-dashboard-kong-proxy.kubernetes-dashboard"
      secure        = true
      no_tls_verify = true
    }
    "longhorn" = {
      name    = "Longhorn"
      service = "http://longhorn-frontend.longhorn-system"
      secure  = true
    }
    "prometheus" = {
      name    = "Prometheus"
      service = "http://kube-prometheus-stack-prometheus.monitoring:9090"
      secure  = true
    }
    "alertmanager" = {
      name    = "Alert Manager"
      service = "http://kube-prometheus-stack-alertmanager.monitoring:9093"
      secure  = true
    }
    "grafana" = {
      name    = "Grafana"
      service = "http://kube-prometheus-stack-grafana.monitoring"
      secure  = false
    }
    "musicbot" = {
      name    = "Music Bot"
      service = "http://sinusbot:8087"
      secure  = false
    }
    "teslamate" = {
      name    = "TeslaMate"
      service = "http://teslamate:4000"
      secure  = true
    }
    "influxdb" = {
      name    = "InfluxDB"
      service = "http://influxdb:8086"
      secure  = true
    }
    "torrent" = {
      name    = "Torrent"
      service = "http://qbittorrent:8080"
      secure  = true
    }
    "adguardhomesync" = {
      name    = "AdGuard Home Sync"
      service = "http://adguard-home:8080"
      secure  = true
    }
  }

  secure_applications = {
    for k, v in local.zero_trust_applications : k => v if v.secure
  }
}

data "cloudflare_zero_trust_access_identity_providers" "main" {
  account_id = var.cloudflare_account_id
}

resource "cloudflare_zero_trust_access_application" "applications" {
  for_each = local.secure_applications

  account_id                = var.cloudflare_account_id
  name                      = each.value.name
  type                      = "self_hosted"
  auto_redirect_to_identity = true
  options_preflight_bypass  = false
  tags                      = []
  allowed_idps = [
    data.cloudflare_zero_trust_access_identity_providers.main.result[0].id
  ]
  destinations = [{
    type = "public"
    uri  = "${each.key}.${data.cloudflare_zone.main.name}"
  }]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.allowed_users.id
      precedence = 1
    },
    {
      id         = cloudflare_zero_trust_access_policy.access_tokens.id
      precedence = 2
    }
  ]
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "ryzen7_5800u_01" {
  account_id = var.cloudflare_account_id
  name       = "ryzen7-5800u-01"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "ryzen7_5800u_01" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.ryzen7_5800u_01]
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.ryzen7_5800u_01.id
  config = {
    warp_routing = {
      enabled = false
    }
    ingress = concat(
      [
        for app_name, app_config in local.zero_trust_applications : {
          hostname = "${app_name}.${data.cloudflare_zone.main.name}"
          service  = app_config.service
          origin_request = {
            access = app_config.secure ? {
              required  = true
              aud_tag   = [cloudflare_zero_trust_access_application.applications[app_name].aud]
              team_name = "abyss23"
            } : null
            no_tls_verify = lookup(app_config, "no_tls_verify", false) ? true : null
          }
        }
      ],
      [
        {
          service = "http_status:404"
        }
      ]
    )
  }
}

resource "cloudflare_dns_record" "zero_trust_tunnel" {
  for_each = local.zero_trust_applications

  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.ryzen7_5800u_01]
  zone_id    = var.cloudflare_zone_id
  name       = "${each.key}.${data.cloudflare_zone.main.name}"
  type       = "CNAME"
  content    = "${cloudflare_zero_trust_tunnel_cloudflared.ryzen7_5800u_01.id}.cfargotunnel.com"
  ttl        = 1
  proxied    = true
}
