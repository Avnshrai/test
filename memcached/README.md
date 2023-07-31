# What is Memcached ?
Memcached is an high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.

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
    "ENV APP_VERSION 1.6.21",
    "ENV COREDGE_APP_NAME memcached",
    "ENV PATH /opt/coredge/memcached/bin:$PATH",
    "EXPOSE 11211",
    "USER 65100",
    "ENTRYPOINT [ \"/opt/coredge/scripts/memcached/entrypoint.sh\"]",
    "CMD [ \"/opt/coredge/scripts/memcached/run.sh\" ]"
  ]
}
```

Choosing base image as `coredgeio/ubuntu-base-beta:v1` and defining entrypoint for `MEMCACHED` service along with exposing `11211` port for memcached and running memcached from `core` user whose UID is `65100`.

*Note-* *Here we are passing `loki.yaml` as config file for loki which is required to run the service.*


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
provisioner "file" {
    source      = "rootfs/"
    destination = "/"
}

  provisioner "file" {
    source  = "prebuildfs/opt/"
    destination = "opt/"
}
```

Providind required files and directory named `rootfs` for service and log execution.

```hcl
provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y wget",
      "apt-get -y install ca-certificates curl libevent-2.1-7 libsasl2-2 libsasl2-modules netcat procps sasl2-bin",
      "mkdir /s5cmd",
      "wget -P /s5cmd https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz ",
      "tar -xzvf /s5cmd/s5cmd_2.1.0_Linux-64bit.tar.gz -C /s5cmd",
      "chmod +x /s5cmd/s5cmd",
      "cp /s5cmd/s5cmd /sbin",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "s5cmd --stat cp 's3://coredgeapplications/memcached/v1.6.21-0/memcached-1.6.21-0-linux-amd64-debian-11.tar.gz' .",
      "tar -zxf memcached-1.6.21-0-linux-amd64-debian-11.tar.gz -C /opt/coredge --strip-components=2 --no-same-owner --wildcards '*/files'",
      "chmod g+rwX /opt/coredge",
      "cd",
      "echo -e \"\n\" > /etc/issue", # Remove the Ubuntu version information and replace it with a new lines,
      "ls -lrth /opt/coredge/scripts/",
      "/bin/bash -o pipefail -c '/opt/coredge/scripts/memcached/postunpack.sh'",
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
```

*Note-* *Here we are fetching Coredge custom memcached binary from AWS S3 using `s5cmd`.*

In Provisioner section defining all the requirements for `loki`.

```hcl
post-processor "docker-tag" {
    repository = "coredge/memcached-packer"
    tags = ["v1"]
}
```
`Post-Processor` section helps to provide image tag.


### Contributors
[![Yogendra Pratap Singh][yogendra_avatar]][yogendra_homepage]<br/>[Yogendra Pratap Singh][yogendra_homepage] 

  [yogendra_homepage]: https://www.linkedin.com/in/yogendra-pratap-singh-41630716b/
  [yogendra_avatar]: https://img.cloudposse.com/75x75/https://github.com/PratapSingh13.png

