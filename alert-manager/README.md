# Packer Configuration for Alert

This Packer configuration is used to build a Docker image for Coredge based on Ubuntu.

## Prerequisites

- Packer (version >= 1.7.0)
- Docker plugin for Packer (version >= 0.0.7)

## Building the Image

1. Clone this repository.
2. Install Packer and the Docker plugin (if not already installed).
3. Navigate to the cloned repository.
4. Run the following command to build the Docker image:

   ```shell
   packer build coredge-image.pkr.hcl
   ```
The Docker image will be built with the name coredge/baseos-beta and the tag alertmanager-0.25.0-5.

## Configuration

The Packer configuration file (*coredge-image.pkr.hcl*) specifies the following:

Docker plugin requirement.
Docker source image based on *coredgeio/ubuntu-base-beta:v1.*
Exposing port *9093* in the Docker image.
Setting the command and entrypoint for the image.
Shell provisioners to perform the following actions:
Creating the *.aws* directory in the root directory.
Copying the AWS credentials and config files to the *.aws* directory.
Installing required packages and tools.
Downloading and installing *s5cmd* for S3 operations.
Downloading and extracting the Alertmanager package.
Setting file permissions and creating necessary directories.
A post-processor to tag the built Docker image with *coredge/baseos-beta:alertmanager-0.25.0-5.*
Please make sure you have the necessary credentials and configurations for AWS before building the image.

## License
This Packer configuration is licensed under the Coredge License.