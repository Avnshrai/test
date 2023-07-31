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
    "ENV APP_VERSION 0.3107.0",
    "ENV COREDGE_APP_NAME jenkins-agent",
    "ENV JAVA_HOME /opt/coredge/java",
    "ENV PATH /opt/coredge/java/bin:$PATH",
    "USER core",
    "ENTRYPOINT [ \"/opt/coredge/scripts/jenkins-agent/entrypoint.sh\"]"
  ]
}
```

Choosing our own ubuntu base image as `coredgeio/ubuntu-base-beta:v1` and defining environment variables, workdir,  Entrypoint for `jenkins-agent` service. This is sort of a docker override.

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

```
In the `build` section we require AWS cli access to fetch binaries from AWS S3. So we are creating `.aws` directory over the `/root/.aws` and placing `credentials` and `config` in the same.
Also we are copying necessary scripts and files required to the destination. We are also changing default container `core` user permissions for relevant access.

```hcl
provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y wget",
      "apt-get install -y ca-certificates curl procps zlib1g",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "mkdir /s5cmd && cd /s5cmd",
      "wget https://github.com/peak/s5cmd/releases/download/v2.1.0/s5cmd_2.1.0_Linux-64bit.tar.gz",
      "tar -xzvf s5cmd_2.1.0_Linux-64bit.tar.gz",
      "chmod +x s5cmd",
      "cp /s5cmd/s5cmd /sbin",
      "cd /opt/coredge",
      "s5cmd --stat cp 's3://coredgeapplications/java/java-11.0.19-7-2/java-11.0.19-7-2-linux-amd64-debian-11.tar.gz' .",
      "s5cmd --stat cp 's3://coredgeapplications/jenkins-agent/jenkins-agent-0.3107.0-5/jenkins-agent-0.3107.0-5-linux-amd64-debian-11.tar.gz' .",
      "tar -zxf java-11.0.19-7-2-linux-amd64-debian-11.tar.gz --strip-components=2",
      "tar -zxf jenkins-agent-0.3107.0-5-linux-amd64-debian-11.tar.gz --strip-components=2",
      "cd",
      "echo -e \"\n\" > /etc/issue",  # Remove the Ubuntu version information and replace it with a new lines,
      "rm -rf /s5cmd",
      "rm /sbin/s5cmd",
      "apt purge wget -y",
      "rm -rf /root/.aws",
      "chmod g+rwX /opt/coredge"
    ]
  }
```
In the `build` section we are using another `shell` provisioner to run our shell commands - Installing necessary packages, binaries, creating required directories. We are also installing `s5cmd`. We are also deleting unnecessary files and packages to keep the image size small. 

*Note-* *Here we are fetching Coredge custom jenkins-agent binary from AWS S3 using `s5cmd`.*

In Provisioner section defining all the requirements for `jenkins-agent`.

```hcl
post-processor "docker-tag" 
{
    repository = "coredge/jenkins-agent-beta"
    tags = ["jenkins-agent-0.3107.0"]
  }
```
`Post-Processor` section helps to provide image tag. It will build the image thru packer and make it available locally with name & tag provided in the `Post-Processor` section.
