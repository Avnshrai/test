packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "scratch" {
  image  = "scratch"
  commit = true
}

variable "image_name" {
  type    = string
  default = "coredge-base-image-v22"
}

build {
  name = "Coredge-image"
  sources = [
    "source.docker.scratch"
  ]

  // provisioner "file" {
  //   source      = "banner.txt"
  //   destination = "/etc/motd"
  // }

  // # Install Prometheus (assuming you have Prometheus binaries in the current directory)
  // provisioner "file" {
  //   source      = "prometheus.yml"
  //   destination = "/prometheus.yml"
  // }

  provisioner "shell" {
    inline = [
      "chmod +x ./prometheus",    # Assuming Prometheus binary is in the current directory
      "mv ./prometheus /bin/",    # Move Prometheus binary to /bin directory
      "mv /prometheus.yml /etc/", # Move Prometheus configuration to /etc directory
    ]
  }

  # Create the 'core' user and give root permissions
  provisioner "shell" {
    inline = [
      "useradd -mU -s /bin/bash -G sudo core -u 65100",               # Create the user 'core' and add to 'sudo' group
      "echo 'core ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/core", # Give 'core' user root permissions without password prompt
    ]
  }

  # Set 'core' as the default user in the container
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/^root:x:0:0:root:\\/root:\\/bin\\/bash$/root::0:0:root:\\/root:\\/usr\\/sbin\\/nologin/' /etc/passwd",
    ]
  }

  // provisioner "ansible" {
  //   playbook_file = "./run.yaml"
  //   extra_arguments = [ "--tags=level_2_server"]
  // }

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
