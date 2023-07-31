# How we are using Packer

```hcl
packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}
```
In above section we are defining the Packer version which is `0.0.7` in my case along with docker source.

```hcl
source "docker" "ubuntu" {
  image  = "coredgeio/ubuntu-base-beta:v1"
  commit = true
  changes = [
    "EXPOSE 9100",
    "ENTRYPOINT [ \"/opt/coredge/node-exporter/bin/node_exporter\"]"
  ]
}
```

Choosing base image as `siddharth387/coredge-base-image:136-a71e788-coredge-base-image-1` and defining entrypoint for `node-exporter` service.

```hcl
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
}
```
In the `build` section we require AWS cli access to fetch binaries from AWS S3, So creating `.aws` directory over the `/root/.aws` and placing `credentials` and `config` in the same.

```hcl
provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y wget",
      "apt-get -y install sudo ca-certificates curl tar",
      "mkdir /opt/coredge",
      "mkdir /s5cmd && cd /s5cmd",
      "wget https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz",
      "tar -xzvf s5cmd_2.1.0_Linux-64bit.tar.gz",
      "chmod +x s5cmd",
      "cp /s5cmd/s5cmd /sbin",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "s5cmd --stat cp 's3://coredgeapplications/node-exporter/v1.6.0.1-amd64/node-exporter-1.6.0-1-linux-amd64-debian-11.tar.gz' .",
      "tar -zxf node-exporter-1.6.0-1-linux-amd64-debian-11.tar.gz -C /opt/coredge --strip-components=2",
      "chmod g+rwX /opt/coredge",
      "cd",
      "echo -e \"\n\" > /etc/issue", # Remove the Ubuntu version information and replace it with a new line,
      "rm -rf /s5cmd",
      "rm /sbin/s5cmd",
      "apt purge wget -y",
      "apt purge curl -y",
      "apt purge passwd -y --allow-remove-essential",
      "rm -rf /tmp/coredge/pkg/cache/node-exporter-1.6.0-1-linux-amd64-debian-11.tar.gz",
      "rm -rf /root/.aws"
    ]
}
```

*Note-* *Here we are fetching Coredge custom node-exporter binary from AWS S3 using `s5cmd`.*

In Provisioner section defining all the requirements for `node-exporter`.

```hcl
post-processor "docker-tag" {
    repository = "coredge/node-exporter-packer"
    tags = ["v1"]
}
```
`Post-Processor` section helps to provide image tag.


### Contributors
[![Yogendra Pratap Singh][yogendra_avatar]][yogendra_homepage]<br/>[Yogendra Pratap Singh][yogendra_homepage] 

  [yogendra_homepage]: https://www.linkedin.com/in/yogendra-pratap-singh-41630716b/
  [yogendra_avatar]: https://img.cloudposse.com/75x75/https://github.com/PratapSingh13.png
