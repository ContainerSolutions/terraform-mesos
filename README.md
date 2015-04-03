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
- Install the SDK and authenticate it with your Google Account
- Once your keypair is created, use the path to the private key and the username in the next step as `gce_ssh_user` and `gce_ssh_private_key_file`

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
    }

See the `variables.tf` file for the available variables and their defaults

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

- How do I call a script from a module?
- Currently no way to retrieve the ip address of the master nodes through Terraform. Use the Google Developers Console to retrieve the ip addresses. 
- Cannot reach the log files of the Mesos slave nodes from the web interface on the leading master
- VPN configuration



The installation and configuration used in this module is based on this excellent howto: <https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04>

  
