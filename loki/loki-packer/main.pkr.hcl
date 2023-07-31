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
    "EXPOSE 3100",
    "ENV PATH /opt/coredge/grafana-loki/bin:$PATH",
    "USER 65100",
    "ENTRYPOINT [ \"loki\" ]",
    "CMD [ \"-config.file=/coredge/grafana-loki/conf/loki.yaml\" ]",
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
    source = "credentials"
    destination = "/root/.aws/credentials"
  }

  provisioner "file" {
    source = "config"
    destination = "/root/.aws/config"
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /coredge/grafana-loki/conf/"
    ]
  }

  provisioner "file" {
    source = "loki.yaml"
    destination = "/coredge/grafana-loki/conf/loki.yaml"
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /opt/coredge",
      "chmod -R +x /opt/*",
      "usermod -G root,sudo core"
    ]
  }

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y wget",
      "apt-get -y install ca-certificates",
      "mkdir -p /coredge/grafana-loki/data /coredge/grafana-loki/loki /coredge/grafana-loki/wal && chmod -R g+rwX /coredge/grafana-loki && ln -s  /coredge/grafana-loki/loki /loki && ln -s /coredge/grafana-loki/data /data && ln -s /coredge/grafana-loki/wal /wal",
      "mkdir /s5cmd && cd /s5cmd",
      "wget https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz",
      "tar -xzvf s5cmd_2.1.0_Linux-64bit.tar.gz",
      "chmod +x s5cmd",
      "cp /s5cmd/s5cmd /sbin",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "s5cmd --stat cp 's3://coredgeapplications/loki/v2.8.2-1/grafana-loki-2.8.2-1-linux-amd64-debian-11.tar.gz' .",
      "tar -zxf grafana-loki-2.8.2-1-linux-amd64-debian-11.tar.gz -C /opt/coredge --strip-components=2",
      "chmod g+rwX /opt/coredge",
      "cd",
      "echo -e \"\n\" > /etc/issue", # Remove the Ubuntu version information and replace it with a new lines,
      "chown -R core:core /opt/coredge/",
      "rm -rf /s5cmd",
      "rm /sbin/s5cmd",
      "apt purge wget -y",
      "apt purge curl -y",
      "apt purge passwd -y --allow-remove-essential",
      "apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives",
      "rm -rf /tmp/coredge/pkg/cache/grafana-loki-2.8.2-1-linux-amd64-debian-11.tar.gz",
      "rm -rf /root/.aws"
    ]
  }

  post-processor "docker-tag" {
    repository = "coredge/loki-packer"
    tags = ["v1"]
  }
}
