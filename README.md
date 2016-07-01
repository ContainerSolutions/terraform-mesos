# Container Solutions Terraform Mesos

## How to set up a Mesos cluster on the Google Cloud using Terraform

### Install Terraform

* This module requires Terraform 0.6.16 or greater
* Follow the instructions on <https://www.terraform.io/intro/getting-started/install.html> to set up Terraform on your machine.

### Get your Google Cloud JSON account_file
Authenticating with Google Cloud services requires a JSON file which we call the account file. This file is downloaded directly from the Google Developers Console. Follow these steps:
- Log into the [Google Developers Console](https://console.developers.google.com/) and select `your google project`.
- The API Manager view should be selected, click on "Credentials" on the left, then "Create credentials", and finally "Service account key".
- Select "Compute Engine default service account" in the "Service account" dropdown, and select "JSON" as the key type.
- Clicking "Create" will download your account_file.

### Get Google Cloud SDK
- Visit https://cloud.google.com/sdk/
- Install the SDK, login and authenticate with your Google Account.

### Add your SSH key to the Project Metadata
- Back in the Developer Console, go to Compute - Compute Engine - Metadata and click the SSH Keys tab. Add your public SSH key there.
- Use the path to the private key and the username in the next step as `gce_ssh_user` and `gce_ssh_private_key_file`

### Prepare Terraform configuration file

Create a file `mesos.tf` containing something like this:

    module "mesos" {
        source                      = "github.com/ContainerSolutions/terraform-mesos"
        account_file                = "/path/to/your.key.json"
        project                     = "your google project"
        region                      = "europe-west1"
        zone                        = "europe-west1-d"
        gce_ssh_user                = "user"
        gce_ssh_private_key_file    = "/path/to/private.key"
        name                        = "mymesoscluster"
        masters                     = "3"
        slaves                      = "5"
        network                     = "10.20.30.0/24"
        domain                      = "example.com"
        mesos_version               = "0.28.0"
        image                       = "rhel-7-v20160418"
        distribution                = "redhat"
        slave_machine_type          = "n1-standard-2"
    }

See the `variables.tf` file for the available variables and their defaults

#### Standard Mesos Ubuntu package

If you set `image` to the standard Ubuntu 15.04 GCE image name, you get the standard Mesos version distributed with this operating system.

    image = "ubuntu-1504-vivid-v20151120"

#### Specific Mesos Ubuntu package version

If you decide to use a specific version of Mesos, which does exist as an Ubuntu package, enter the version number to the optional `mesos_version` configuration option.

    image = "ubuntu-1504-vivid-v20151120"
    mesos_version = "0.25.0-0.2.70.ubuntu1504"

#### Mesos built from a specific git commit

You might want to try Mesos installed from a specific commit (e.g. "69d4cf654", or "master"). In order to do it, build a GCE virtual machine image (see [images/README.md](images/README.md)) with Mesos installed and use the `GCE_IMAGE_NAME` you give it as the `image` configuration option, e.g.:

    image = "ubuntu-1404-trusty-mesos"

### Get the Terraform module

Download the module

```
terraform get -update
```

### Create Terraform plan

Create the plan and save it to a file. Use module-depth 1 to show the configuration of the resources inside the module.

```
terraform plan -out my.plan -module-depth=1
```

### Create the cluster

Once you are satisfied with the plan, apply it.

```
terraform apply my.plan
```

### VPN configuration

Ports 80, 443 and 22 are open on all the machines within the cluster. Accessing other ports, e.g. Mesos GUI (port 5050) or Marathon GUI (port 8080) is only possible with VPN connection set up.

Use the following commands to download `client.ovpn` file. Then use it to establish VPN with the cluster.

```
OVPNFILE=`terraform output -module mesos openvpn`
scp -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $OVPNFILE .
sudo openvpn --config client.ovpn
```

### Visit the web interfaces
Once the VPN is up, you can access all machines within the cluster using their private IP addresses. Open a second tab to execute the following commands

```
export INTERNAL_IP_M0=`gcloud compute instances list --regexp .*master-0.* --format='value(networkInterfaces[].networkIP.list())'`
open http://$INTERNAL_IP_M0:5050 # Mesos Console
open http://$INTERNAL_IP_M0:8080 # Marathon Console
mesos config master zk://$INTERNAL_IP_M0:2181/mesos # for those who have the local mesos client installed
curl -s $INTERNAL_IP_M0:5050/master/slaves | python -mjson.tool | grep -e pid -e disk -e cpus
```

### Destroy the cluster
When you're done, clean up the cluster with
```
terraform destroy
```

## To do

- Cannot reach the log files of the Mesos slave nodes from the web interface on the leading master

The installation and configuration used in this module is based on this excellent howto: <https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04>
