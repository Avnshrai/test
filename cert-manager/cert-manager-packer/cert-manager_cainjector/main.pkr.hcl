packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "cainjector" {
  image  = "coredgeio/ubuntu-base-beta:v1"
  commit = true
  changes = [
    "ENV APP_VERSION 1.12.2",
    "ENV PATH /opt/coredge/cainjector/bin:$PATH",
    "ENV COREDGE_APP_NAME=cainjector",
    "USER 65100",
    "WORKDIR /opt/coredge/cainjector",
    "ENTRYPOINT [\"/opt/coredge/cainjector/bin/cainjector\"]"
  ]
}

build {
  name = "Coredge-image"
  sources = [
    "source.docker.cainjector"
  ]
  provisioner "shell" {
    inline = [
      "mkdir /root/.aws"
    ]
  }

  provisioner "file" {
    source = "credentials"
    destination = "/root/.aws/credentials"
  }

  provisioner "file" {
    source = "config"
    destination = "/root/.aws/config"
  }
  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install ca-certificates -y",
      "apt-get install curl wget  -y", 
      "apt-get install procps -y",
      "mkdir -p /opt/coredge",
      "mkdir /s5cmd && cd /s5cmd",
      "wget https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz",
      "tar -xzvf s5cmd_2.1.0_Linux-64bit.tar.gz",
      "chmod +x s5cmd",
      "cp /s5cmd/s5cmd /sbin",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "s5cmd --stat cp 's3://coredgeapplications/cert-manager/v1.12.2-amd64/cainjector-1.12.2-0-linux-amd64-debian-11.tar.gz' .",
      "tar -zxf cainjector-1.12.2-0-linux-amd64-debian-11.tar.gz -C /opt/coredge --strip-components=2 --no-same-owner",
      "rm -rf cainjector-1.12.2-0-linux-amd64-debian-11.tar.gz{,.sha256}",
      "apt-get autoremove --purge -y curl && apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives",
      "chmod g+rwX /opt/coredge/",
      "rm -rf /s5cmd",
      "rm /sbin/s5cmd",
      "echo -e \"\n\" > /etc/issue",
      "rm -rf /root/.aws"
    ]
  }
  provisioner "shell" {
    inline = [
      "chmod -R +x /opt/*"
    ]
  }
  post-processor "docker-tag" {
    repository = "coredge/certmanager-cainjector"
    tags = ["test"]
  }
}
