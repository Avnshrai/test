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
    "EXPOSE 8080 8443 50000",
    "ENV APP_VERSION 2.387.3",
    "ENV COREDGE_APP_NAME jenkins",
    "ENV JAVA_HOME /opt/coredge/java",
    "ENV PATH /opt/coredge/common/bin:/opt/coredge/java/bin:$PATH",
    "USER core",
    "ENTRYPOINT [ \"/opt/coredge/scripts/jenkins/entrypoint.sh\"]",
    "CMD [ \"/opt/coredge/scripts/jenkins/run.sh\" ]"
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

  
  provisioner "file" {
    source  = "prebuildfs/"
    destination = "/"
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
      "apt-get install -y ca-certificates curl fontconfig git jq libfontconfig1 openssh-client procps unzip zlib1g",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "mkdir /s5cmd && cd /s5cmd",
      "wget https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz",
      "tar -xzvf s5cmd_2.1.0_Linux-64bit.tar.gz",
      "chmod +x s5cmd",
      "cp /s5cmd/s5cmd /sbin",
      "cd /opt/coredge",
      "s5cmd --stat cp 's3://coredgeapplications/render-template/render-template-1.0.5-6/render-template-1.0.5-6-linux-amd64-debian-11.tar.gz' .",
      "s5cmd --stat cp 's3://coredgeapplications/java/java-11.0.19-7-2/java-11.0.19-7-2-linux-amd64-debian-11.tar.gz' .",
      "s5cmd --stat cp 's3://coredgeapplications/jenkins/jenkins-2.387.3-1/jenkins-2.387.3-1-linux-amd64-debian-11.tar.gz' .",
      "tar -zxf render-template-1.0.5-6-linux-amd64-debian-11.tar.gz  --strip-components=2",
      "tar -zxf java-11.0.19-7-2-linux-amd64-debian-11.tar.gz --strip-components=2",
      "tar -zxf jenkins-2.387.3-1-linux-amd64-debian-11.tar.gz --strip-components=2",
      "cd",
      "echo -e \"\n\" > /etc/issue",  # Remove the Ubuntu version information and replace it with a new lines,
      "rm -rf /s5cmd",
      "rm /sbin/s5cmd",
      "apt purge wget -y",
      "rm -rf /root/.aws",
      "chmod g+rwX /opt/coredge"
    ]
  }

  
  provisioner "file" {
    source      = "rootfs/"
    destination = "/"
  }


  
  provisioner "shell" {
    inline = [
      "chmod -R +x /opt/*",
      "/opt/coredge/scripts/java/postunpack.sh",
      "/opt/coredge/scripts/jenkins/postunpack.sh"
      
    ]
  }
  
  provisioner "shell" {
    inline = [
       "sudo apt purge bzip* *ldap* -y && sudo apt autoremove -y && sudo apt clean",
       "sudo rm -rf /var/lib/apt/lists /var/cache/apt/archives ",
    ]
  }
  post-processor "docker-tag" {
    repository = "coredge/jenkins-beta"
    tags = ["jenkins-2.387.3"]
  }
}
