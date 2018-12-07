resource "null_resource" "graylog" {
  depends_on = ["digitalocean_droplet.graylog"]

  connection {
    host        = "${digitalocean_droplet.graylog.ipv4_address}"
    user        = "root"
    type        = "ssh"
    private_key = "${file(var.pvt_key)}"
    timeout     = "2m"
  }

  # put elastic config file
  provisioner "file" {
    content     = "${data.template_file.elastic_yml.rendered}"
    destination = "/etc/elasticsearch/elasticsearch.yml"
  }

  provisioner "file" {
    content     = "${data.template_file.nginx.rendered}"
    destination = "/etc/nginx/sites-available/default"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /bin/systemctl daemon-reload",
      "sudo /bin/systemctl enable elasticsearch.service",
      "sudo systemctl start elasticsearch.service",
      "sudo systemctl restart elasticsearch.service",
      "sudo /bin/systemctl daemon-reload",
      "sudo /bin/systemctl enable mongod.service",
      "sudo systemctl start mongod.service",
      "sudo systemctl restart mongod.service",
      "sudo /bin/systemctl daemon-reload",
      "sudo systemctl enable graylog-server",
      "sudo systemctl start graylog-server",
      "sudo systemctl restart graylog-server",

      # temporary disable nginx
      "sudo systemctl stop nginx",
    ]
  }
}
