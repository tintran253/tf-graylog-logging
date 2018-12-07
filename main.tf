resource "digitalocean_droplet" "graylog" {
  image              = "ubuntu-18-10-x64"
  name               = "graylog"
  region             = "sgp1"
  size               = "4gb"
  private_networking = true
  backups            = true

  ssh_keys = [
    "${var.ssh_fingerprint}",
  ]

  connection {
    user        = "root"
    type        = "ssh"
    private_key = "${file(var.pvt_key)}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",

      # install java 8
      "sudo add-apt-repository -y ppa:webupd8team/java",

      "sudo apt-get update",
      "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections",
      "echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
      "sudo apt-get -y install oracle-java8-installer",
      "export JAVA_HOME=/usr/lib/jvm/java-8-oracle",
      "sudo apt-get update",
      "echo $JAVA_HOME",

      # install elastic
      "wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.1.deb",

      "wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.1.deb.sha512",
      "shasum -a 512 -c elasticsearch-6.5.1.deb.sha512",
      "sudo dpkg -i elasticsearch-6.5.1.deb",

      # install mongdb
      "wget https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/4.0/multiverse/binary-amd64/mongodb-org-server_4.0.4_amd64.deb",

      "sudo dpkg -i mongodb-org-server_4.0.4_amd64.deb",

      # install graylog
      "sudo apt-get install apt-transport-https",

      "wget https://packages.graylog2.org/repo/packages/graylog-2.5-repository_latest.deb",
      "sudo dpkg -i graylog-2.5-repository_latest.deb",
      "sudo apt-get update",
      "sudo apt-get install graylog-server",

      # install nginx
      "sudo apt-get update",

      "sudo apt-get -y install nginx",
    ]
  }
}
