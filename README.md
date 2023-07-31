# marketplace-apps
For Curated CE apps for maketplace
The Coredge Containers Library

Popular applications, provided by Coredge, containerized and ready to launch.


Why use Coredge Images?
Coredge closely tracks upstream source changes and promptly publishes new versions of this image using our automated systems. With Coredge images the latest bug fixes and features are available as soon as possible.
Coredge containers use the same components and configuration approach, making switching between formats based on your project needs easy.
 All our images are based on Ubuntu 20.04 a minimalist Ubuntu-based container image that gives you a small base container image and the familiarity of a leading Linux distribution.

 Coredge container images are released on a regular basis with the latest distribution packages available.

Get an Image :


The recommended way to get any of the Coredge Images is to pull the prebuilt image from the Docker Hub Registry.

docker pull Coredge/APP

To use a specific version, you can pull a versioned tag.

docker pull Coredge/APP:[TAG]


Remember to replace the APP, VERSION and OPERATING-SYSTEM placeholders in the example command above with the correct values.



The main folder of each application contains two subfolders  one folder consists of Packer build files and another one helm chart for the app.
This repo will be forked to keep the Packer and Helm files in separate repository.
   
    
Vulnerability scan in Coredge container images

As part of the release process, the Coredge container images are analyzed for vulnerabilities. At this moment, we are using two different tools:

    Trivy


This scanning process is triggered as part of CI pipeline for every PR affecting the source code of the containers, regardless of its nature or origin.
