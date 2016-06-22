# Container Solutions Terraform Mesos

## How to set up a Mesos cluster on the Google Cloud using Terraform

### Install Terraform

* This module requires Terraform 0.6.2 or greater
* Follow the instructions on <https://www.terraform.io/intro/getting-started/install.html> to set up Terraform on your machine.

### Get your Google Cloud JSON Key
- Go to the [Developers Console Credentials](https://console.developers.google.com/project/_/apis/credentials) page.
- From the project drop-down, select `your google project`. If not exist, first create `your google project`.
- On the Credentials page, select the Create credentials drop-down, then select Service account key.
- From the Service account drop-down, select the existing `Compute Engine default service account`.
- For Key type, select the JSON key option, then select Create. The `account_file` automatically downloads to your computer.

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
        project                     = "your google project ID"
        region                      = "europe-west1"
        zone                        = "europe-west1-d"
        gce_ssh_user                = "user"
        gce_ssh_private_key_file    = "/path/to/private.key"
        name                        = "mymesoscluster"
        masters                     = "3"
        slaves                      = "5"
        network                     = "10.20.30.0/24"
        domain                      = "example.com"
        mesos_version               = "0.28.2"
        image                       = "rhel-7-v20160606"
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
terraform get
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

Get the external IP address of the `module.mesos.google_compute_instance.mesos-master.0` VPN server
```
gcloud config set project <project> # your google project ID
export EXTERNAL_IP_M0=`gcloud compute instances list --regexp .*master-0.* --format='value(networkInterfaces[].accessConfigs[].natIP:label=EXTERNAL_IP.list)' | awk -F"'" '$0=$2'`
echo $EXTERNAL_IP_M0
```

Use the following command to get the location of `client.ovpn` file, that was created as part of the cluster provisioning.

```
terraform output -module mesos openvpn
```

Download the `client.ovpn` file using e.g. `scp` and use it to establish VPN with the cluster. Once the VPN is up, you can access all machines within the cluster using their private IP addresses.

### Visit the web interfaces
When the cluster is set up, check the Google Developers Console for the *internal* addresses of the master nodes (or scroll back in the output of the apply step to retrieve them). Or use this script:
```
export INTERNAL_IP_M0=`gcloud compute instances list --regexp .*master-0.* --format='value(networkInterfaces[].networkIP.list())'`
echo $INTERNAL_IP_M0
open http://$INTERNAL_IP_M0:5050 # Mesos Console
open http://$INTERNAL_IP_M0:8080 # Marathon Console
```

### Destroy the cluster
When you're done, clean up the cluster with
```
terraform destroy
```

## To do

- Cannot reach the log files of the Mesos slave nodes from the web interface on the leading master

The installation and configuration used in this module is based on this excellent howto: <https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04>
