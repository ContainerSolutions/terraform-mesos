# Container Solutions Terraform Mesos

## How to set up a Mesos cluster on the Google Cloud using Terraform

### Install Terraform
Follow the instructions on <https://www.terraform.io/intro/getting-started/install.html> to set up Terraform on your machine.

### Get your Google Cloud JSON Key
- Visit https://console.developers.google.com
- Navigate to APIs & Auth -> Credentials -> Service Account -> Generate new JSON key
- The file will be downloaded to your machine

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
        localaddress                = "92.111.228.8/32"
        domain                      = "example.com"
        image                       = "ubuntu-1404-trusty-v20150316"
    }

See the `variables.tf` file for the available variables and their defaults

### Choose Mesos version

Tell the module, implicitly or explicitly, which version of Mesos you want to use, by setting the `image` and optionally `mesos_version` configuration options.

#### Standard Mesos Ubuntu package

If you set `image` to the standard Ubuntu 14.04 GCE image name, you get the standard Mesos version distributed with this operating system.

    image = "ubuntu-1404-trusty-v20150316"

#### Specific Mesos Ubuntu package version

If you decide to use a specific version of Mesos, which does exist as an Ubuntu package, enter the version number to the optional `mesos_version` configuration option.

    image = "ubuntu-1404-trusty-v20150316"
    mesos_version = "0.22.1"

#### Mesos built from a specific git commit

You might want to try Mesos installed from a specific commit (e.g. "69d4cf654", or "master"). In order to do it, build a GCE virtual machine image (see [images/README.md](images/README.md)) with Mesos installed and use the `GCE_IMAGE_NAME` you give it as the `image` configuration option, e.g.:
    
    image = "ubuntu-1404-trusty-mesos"

### Get the Terraform module

Download the module

```terraform get```

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

Use the following command to get the location of `client.ovpn` file, that was created as part of the cluster provisioning.

```
terraform output -module mesos openvpn
```

Download the `client.ovpn` file using e.g. `scp` and use it to establish VPN with the cluster. Once the VPN is up, you can access all machines within the cluster using their private IP addresses.

### Visit the web interfaces
When the cluster is set up, check the Google Developers Console for the addresses of the master nodes (or scroll back in the output of the apply step to retrieve them).
- Go to <http://ipaddress:5050> for the Mesos Console 
- and <http://ipaddress:8080> for the Marathon Console


### Destroy the cluster
When you're done, clean up the cluster with
```
terraform destroy
```

## To do

- Cannot reach the log files of the Mesos slave nodes from the web interface on the leading master
- VPN configuration



The installation and configuration used in this module is based on this excellent howto: <https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04>

  
