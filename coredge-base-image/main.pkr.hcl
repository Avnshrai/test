packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:focal"
  commit = true
  // changes = [
  //   "USER 65100",
  //   ]
}

variable "image_name" {
  type    = string
  default = "coredge-base-image-v22"
}

build {
  name = "Coredge-image"
  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt-get update",
      "apt-get install sudo -y",
      "DEBIAN_FRONTEND=noninteractive apt-get install python3 -y",
      "echo -e \"\n\" > /etc/issue", # Remove the Ubuntu version information and replace it with new lines
      "echo '[ ! -z \"$TERM\" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd' >> /etc/bash.bashrc",
    ]
  }

  provisioner "file" {
    source      = "banner.txt"
    destination = "/etc/motd"
  }

  # Create the 'core' user and give root permissions
  provisioner "shell" {
    inline = [
      "useradd -mU -s /bin/bash -G sudo core -u 65100",               # Create the user 'core' and add to 'sudo' group
      "echo 'core ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/core", # Give 'core' user root permissions without password prompt
      "echo "
    ]
  }

  # Set 'core' as the default user in the container
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/^root:x:0:0:root:\\/root:\\/bin\\/bash$/root::0:0:root:\\/root:\\/usr\\/sbin\\/nologin/' /etc/passwd",
    ]
  }
  provisioner "ansible" {
    playbook_file = "./run.yaml"
    extra_arguments = [ "--tags=level_2_server"]
  }
  provisioner "shell" {
    inline = [
       "sudo apt purge bzip* *ldap* -y && sudo apt autoremove -y && sudo apt clean",
       "sudo apt purge python3* -y && sudo apt autoremove -y && sudo rm -rf /var/lib/apt/lists /var/cache/apt/archives /var/log/lastlog",
    ]
  }
  post-processor "docker-tag" {
    repository = "coredge/baseos-beta"
    tags       = ["coredge-base-image-1"]
  }
}