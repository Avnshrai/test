# Packer Configuration for Coredge Ubuntu Docker Image

This repository contains the Packer configuration file used to build a Docker image based on Ubuntu for the Coredge project. The Docker image is customized for MongoDB deployment.

## Prerequisites

Before building the image, ensure that you have the following prerequisites:

- Packer installed on your system
- Docker plugin version 0.0.7 or later

## Usage

To build the Coredge Ubuntu Docker image, follow these steps:

1. Clone this repository to your local machine.
2. Make sure you have the required plugins specified in the `packer` block installed. If not, run the following command:

```shell
packer init .
```
Run the following command to build the image:
```shell
packer build .
```
This command will start the build process using the specified Packer configuration.

1. Once the build process is complete, the Docker image will be available in your local Docker environment with the tag coredge/ubuntu-packer:mongo.
## Packer Configuration Details

The Packer configuration file **(packer.hcl)** contains the following sections:

## packer Block
The packer block defines the required plugins for the build process. It specifies the Docker plugin and its version from the official HashiCorp GitHub repository.

## source Block
The source block defines the base Docker image to use for building the Coredge image. In this case, it uses the coredgeio/ubuntu-base-beta:v1 image. It also includes a set of changes that customize the image for MongoDB deployment, such as exposing port 27017 and setting environment variables.

## build Block
The build block specifies the build configuration for the image. It sets the name of the build to "Coredge-image" and references the docker.ubuntu source defined in the source block.

The provisioner blocks within the build block define the steps to provision the image. It includes commands to create directories, copy files, install dependencies, download required files from S3, extract the files, and execute post-unpack scripts.

## post-processor Block
The post-processor block defines a post-processing step to tag the final Docker image with the repository name "coredge/ubuntu-packer" and the tag "mongo".


## Contributions

Contributions to this project are welcome. If you encounter any issues or have suggestions for improvements, please create an issue or submit a pull request.
