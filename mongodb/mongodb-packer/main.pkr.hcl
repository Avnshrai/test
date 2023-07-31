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
    "EXPOSE 27017",
    "USER 65100",
    "ENV COREDGE_APP_NAME=mongodb",
    "ENV PATH /opt/coredge/mongodb/bin:/opt/coredge/common/bin:$PATH",
    "ENTRYPOINT [ \"/opt/coredge/scripts/mongodb/entrypoint.sh\"]",
    "CMD [ \"/opt/coredge/scripts/mongodb/run.sh\" ]"
  ]
}

build {
  name = "Coredge-image"
  sources = [
    "docker.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "mkdir /root/.aws"
    ]
  }

  provisioner "file" {
    source      = "/root/credentials"
    destination = "/root/.aws/credentials"
  }

  provisioner "file" {
    source      = "/root/config"
    destination = "/root/.aws/config"
  }

  provisioner "shell" {
    inline = [
      "usermod -G root,sudo core"
    ]
  }

  provisioner "file" {
    source  = "prebuildfs/"
    destination = "/"
  }
  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y wget",
      "apt-get install -y ca-certificates libhogweed5 curl libcurl4 libbrotli1 libcom-err2 libffi7 libgcc-s1 libgcrypt20 libgmp10 libgnutls30 libgpg-error0 libgssapi-krb5-2 libidn2-0 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.4-2 liblzma5 libnettle7 libnghttp2-14 libp11-kit0 libpsl5 librtmp1 libsasl2-2 libssh2-1 libssl1.1 libtasn1-6 libunistring2 numactl procps zlib1g",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "mkdir /s5cmd && cd /s5cmd",
      "wget https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz",
      "tar -xzvf s5cmd_2.1.0_Linux-64bit.tar.gz",
      "chmod +x s5cmd",
      "cp /s5cmd/s5cmd /sbin",
      "cd /opt/coredge",
      "s5cmd --stat cp 's3://coredgeapplications/mongodb/mongodb-6.0.6-1/mongodb-6.0.6-1-linux-amd64-debian-11.tar.gz' .",
      "s5cmd --stat cp 's3://coredgeapplications/mongodb/mongodb-shell/mongodb-shell-1.9.1-0-linux-amd64-debian-11.tar.gz' .",
      "s5cmd --stat cp 's3://coredgeapplications/mongodb/render-template/render-template-1.0.5-6-linux-amd64-debian-11.tar.gz' .",
      "s5cmd --stat cp 's3://coredgeapplications/mongodb/wait-for-port/wait-for-port-1.0.6-7-linux-amd64-debian-11.tar.gz' .",
      "s5cmd --stat cp 's3://coredgeapplications/mongodb/yq-4.34.1-0/yq-4.34.1-0-linux-amd64-debian-11.tar.gz' .",
      "tar -zxvf mongodb-6.0.6-1-linux-amd64-debian-11.tar.gz --strip-components=2",
      "tar -zxvf mongodb-shell-1.9.1-0-linux-amd64-debian-11.tar.gz --strip-components=2",
      "tar -zxvf wait-for-port-1.0.6-7-linux-amd64-debian-11.tar.gz --strip-components=2",
      "tar -zxvf render-template-1.0.5-6-linux-amd64-debian-11.tar.gz --strip-components=2",
      "tar -zxvf yq-4.34.1-0-linux-amd64-debian-11.tar.gz --strip-components=2",
      "rm -rf /s5cmd",
      "rm /sbin/s5cmd",
      "apt purge wget -y",
      "rm -rf /root/.aws",
      "chmod g+rwX /opt/coredge",
      "cd /opt/coredge",
      "rm mongodb-6.0.6-1-linux-amd64-debian-11.tar.gz mongodb-shell-1.9.1-0-linux-amd64-debian-11.tar.gz wait-for-port-1.0.6-7-linux-amd64-debian-11.tar.gz yq-4.34.1-0-linux-amd64-debian-11.tar.gz render-template-1.0.5-6-linux-amd64-debian-11.tar.gz",
    ]
  }

  provisioner "file" {
    source      = "rootfs/"
    destination = "/"
  }

  provisioner "shell" {
    inline = [
      "/opt/coredge/scripts/mongodb/postunpack.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "apt-get autoremove --purge -y curl && apt-get update && apt-get upgrade -y",
      "apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives"
    ]
  }

  post-processor "docker-tag" {
    repository = "coredge/ubuntu-packer"
    tags = ["mongo"]
  }
}
