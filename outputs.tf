output "ip" {
  value = "${digitalocean_droplet.graylog.ipv4_address}"
}
