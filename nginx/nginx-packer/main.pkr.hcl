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
    "EXPOSE 8080 8443",
    "ENV COREDGE_APP_NAME nginx",
    "USER 65100",
    "ENV PATH /opt/coredge/common/bin:/opt/coredge/nginx/sbin:$PATH",
    "ENTRYPOINT [ \"/opt/coredge/scripts/nginx/entrypoint.sh\"]",
    "CMD [ \"/opt/coredge/scripts/nginx/run.sh\" ]"
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
    source      = "credentials"
    destination = "/root/.aws/credentials"
  }
  provisioner "file" {
    source      = "config"
    destination = "/root/.aws/config"
  }

  provisioner "shell" {
    inline = [
      "usermod -G root,sudo core"
    ]
  }

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y wget",
      "sudo apt install -y file",
      "apt-get install -y ca-certificates curl libcrypt1 libgeoip1 libpcre3 libssl1.1 openssl procps zlib1g",
      "mkdir /opt/coredge",
      "mkdir /opt/coredge/data",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "mkdir /s5cmd && cd /s5cmd",
      "wget https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz",
      "tar -xzvf s5cmd_2.1.0_Linux-64bit.tar.gz",
      "chmod +x s5cmd",
      "cp /s5cmd/s5cmd /sbin",
      "cd /opt/coredge",
      "s5cmd --stat cp 's3://coredgeapplications/nginx/nginx-1.25.0-1/nginx-1.25.0-linux-amd64-debian-11-coredge.tar.gz' .",
      "s5cmd --stat cp 's3://coredgeapplications/nginx/render-template-1.0.5-6/render-template-1.0.5-6-linux-amd64-debian-11.tar.gz' .",
      "tar -zxvf nginx-1.25.0-linux-amd64-debian-11-coredge.tar.gz --strip-components=2",
      "tar -zxvf render-template-1.0.5-6-linux-amd64-debian-11.tar.gz --strip-components=2",
      "cd",
      "echo -e \"\n\" > /etc/issue",  # Remove the Ubuntu version information and replace it with a new lines,
      "rm -rf /s5cmd",
      "rm /sbin/s5cmd",
      "apt purge wget -y",
      "rm -rf /root/.aws",
      "chmod g+rwX /opt/coredge",
      "chown -R core:root /opt/coredge/",
      "mkdir /coredge",
    ]
  }

  provisioner "file" {
    source  = "prebuildfs/"
    destination = "/"
  }
  provisioner "file" {
    source      = "rootfs/"
    destination = "/"
  }

  
  provisioner "shell" {
    inline = [
      "chmod -R +x /opt/*",
      "/opt/coredge/scripts/nginx/postunpack.sh",
      "mkdir -p /opt/coredge/nginx/logs/",
      "touch /opt/coredge/nginx/logs/error.log",
      "touch /opt/coredge/nginx/logs/access.log",
      "ln -sf /dev/stdout /opt/coredge/nginx/logs/access.log",
      "ln -sf /dev/stderr /opt/coredge/nginx/logs/error.log",
    ]
  }
  
  provisioner "shell" {
    inline = [
       "sudo apt purge bzip* *ldap* -y && sudo apt autoremove -y && sudo apt clean",
       "sudo rm -rf /var/lib/apt/lists /var/cache/apt/archives ",
    ]
  }
  post-processor "docker-tag" {
    repository = "coredge/ubuntu-packer"
    tags = ["nginx-9.5.3-0"]
  }
}

