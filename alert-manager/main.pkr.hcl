packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "coredgeio/ubuntu-base-beta:v1"
  commit = true
  changes = [
    "EXPOSE 9093",
    "CMD [ \"--config.file=/opt/coredge/alertmanager/conf/config.yml\", \"--storage.path=/opt/coredge/alertmanager/data\"]",
    "ENTRYPOINT [ \"/opt/coredge/alertmanager/bin/alertmanager\"]"
  ]
}

build {
  name = "Coredge-image"
  sources = [
    "source.docker.ubuntu"
  ]
  provisioner "shell" {
    inline = [
      "mkdir /root/.aws"
    ]
  }

  provisioner "file" {
    source = "/root/credentials"
    destination = "/root/.aws/credentials"
  }

  provisioner "file" {
    source = "/root/config"
    destination = "/root/.aws/config"
  }

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get -y install sudo ca-certificates curl tar wget",
      "mkdir /opt/coredge",
      "sudo mkdir /s5cmd && cd /s5cmd",
      "sudo wget https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz",
      "sudo tar -xzvf s5cmd_2.1.0_Linux-64bit.tar.gz",
      "sudo chmod +x s5cmd",
      "sudo cp /s5cmd/s5cmd /sbin",
      "sudo mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "sudo s5cmd --stat cp 's3://coredgeapplications/alert-manager/v0.25.0-amd64/alertmanager-0.25.0-5-linux-amd64-debian-11.tar.gz' .",
      "tar -zxf alertmanager-0.25.0-5-linux-amd64-debian-11.tar.gz -C /opt/coredge --strip-components=2",
      "chmod g+rwX /opt/coredge",
      "ln -sf /opt/coredge/alertmanager/conf /etc/alertmanager",
      "ln -sf /opt/coredge/alertmanager/data /alertmanager",
      "chmod g+rwX /opt/coredge",
      "mkdir -p /opt/coredge/alertmanager/data/ && chmod g+rwX /opt/coredge/alertmanager/data/",
    ]
  }

  post-processor "docker-tag" {
    repository = "coredge/baseos-beta"
    tags = ["alertmanager-0.25.0-5"]
  }
}

