# Build VM image with Apache Mesos

Use [Packer](https://packer.io/) to build GCE image with a specific version of [Apache Mesos](http://mesos.apache.org/) installed. The GCE image can later be referred in `image` variable passed to the [Terraform module](https://github.com/ContainerSolutions/terraform-mesos). 

## Usage

Install Packer and run the following script in `images` directory of this project, with your values for `GCE_ACCOUNT_FILE`, `GCE_PROJECT_ID` and `GCE_ZONE`. `GCE_IMAGE_NAME` will be the name of your new image. For `MESOS_VERSION` enter either a version number in "0.22.1" format or a valid git commit identifier, branch or tag name from the official Mesos git repository, which is [https://git-wip-us.apache.org/repos/asf/mesos.git](https://git-wip-us.apache.org/repos/asf/mesos.git).

This tool tries to install Mesos from an Ubuntu package, if it exists, or build and install it from sources.

```
FILENAME="mesos.json"
GCE_ACCOUNT_FILE="/Users/Jaroslav/.terraform/terraform-mesos.json"
GCE_PROJECT_ID="terraform-mesos"
GCE_IMAGE_NAME="ubuntu-1404-trusty-mesos"
GCE_ZONE="europe-west1-d"
MESOS_VERSION="0.22.1"

packer validate $FILENAME
packer build \
 -var "gce_account_file=$GCE_ACCOUNT_FILE" \
 -var "gce_project_id=$GCE_PROJECT_ID" \
 -var "gce_image_name=$GCE_IMAGE_NAME" \
 -var "gce_zone=$GCE_ZONE" \
 -var "mesos_version=$MESOS_VERSION" \
 $FILENAME
 ```