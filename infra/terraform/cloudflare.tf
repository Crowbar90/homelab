resource "cloudflare_zero_trust_tunnel_cloudflared" "k3s_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "homelab-k3s"
  config_src = "cloudflare"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "k3s_tunnel_token" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.k3s_tunnel.id
}

output "k3s_tunnel_token" {
  value = data.cloudflare_zero_trust_tunnel_cloudflared_token.k3s_tunnel_token.token
  sensitive = true
}
resource "cloudflare_dns_record" "k3s_root" {
  zone_id = var.cloudflare_zone_id
  name    = "k3s"
  content = "192.168.40.40"
  type    = "A"
  proxied = false
}

resource "cloudflare_dns_record" "k3s_wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.k3s"
  content = "k3s.middleearth.cc"
  type    = "CNAME"
  proxied = false
}
