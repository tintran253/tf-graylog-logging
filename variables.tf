variable "do_token" {}

variable "pvt_key" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_fingerprint" {}

variable "ports" {
  type = "map"

  default = {
    "elasticsearch" = 9200
  }
}

variable "slack_hook_url" {
  default = ""
}

data "template_file" "elastic_yml" {
  template = "${file("./configs/elastic/elasticsearch.yml")}"

  vars {
    elasticsearch_port = "${lookup(var.ports,"elasticsearch")}"
    slack_hook_url     = "${var.slack_hook_url}"
  }
}

data "template_file" "graylog" {
  template = "${file("./configs/graylog/server.conf")}"

  vars {
    ip = "${digitalocean_droplet.graylog.ipv4_address}"
  }
}

data "template_file" "nginx" {
  template = "${file("./configs/nginx/default")}"
}
