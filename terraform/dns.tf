locals {
  dns_records = [
    "@",
    "abyss",
    "cdn",
    "gpt",
    "hello-world-direct",
    "send",
    "ts",
    "convert",
    "minecraft-forge",
    "minecraft-vanilla",
    "homeassistant",
    "octoprint",
    "plex",
  ]
  proxied_records = {
    "cdn" = true,
    "@"   = true,
  }
}

data "cloudflare_dns_record" "home" {
  zone_id = var.cloudflare_zone_id
  filter = {
    name = {
      exact = "home.${data.cloudflare_zone.main.name}"
    }
    type  = "A"
    match = "all"
  }
}

resource "cloudflare_dns_record" "dns" {
  for_each = toset(local.dns_records)

  zone_id = var.cloudflare_zone_id
  name    = each.key == "@" ? data.cloudflare_zone.main.name : "${each.key}.${data.cloudflare_zone.main.name}"
  type    = "CNAME"
  content = data.cloudflare_dns_record.home.name
  ttl     = 1
  proxied = lookup(local.proxied_records, each.key, false)
}

resource "cloudflare_dns_record" "minecraft_vanilla_srv" {
  zone_id  = var.cloudflare_zone_id
  type     = "SRV"
  name     = "_minecraft._tcp.minecraft-vanilla.${data.cloudflare_zone.main.name}"
  ttl      = 1
  priority = 0

  data = {
    proto   = "_tcp"
    name    = "minecraft-vanilla.${data.cloudflare_zone.main.name}"
    weight  = 5
    priority = 0
    port    = 25575
    target  = "minecraft-vanilla.${data.cloudflare_zone.main.name}"
  }
}

data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}
