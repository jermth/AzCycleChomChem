# Using CycleCloud for setting up an Grid Engine cluster for Computational Chemistry on Azure

This repo is an example of a CycleCloud project for creating customized clusters. The instructions below assume that you already have a CycleCloud server installed, with the CycleCloud CLI and the pogo CLI available as well. If the ARM template was used for the CycleCloud installation, these requirements are met.

Also, you should have already configured the CycleCloud installation with a valid license and have set up an Azure subscription in it.


## CycleCloud Projects

[CycleCloud Projects](https://docs.cyclecomputing.com/administrator-guide-v6.5.5/projects) are collections of resources necessary to define and create clusters within CycleCloud. 

There are a couple of preparation steps needed to set up projects for use:
1. An initialized CycleCloud CLI for the CycleCloud installation.
2. A configured pogo config for the storage account.

### Initializing CycleCloud CLI
If you have not done so already, connect your CLI to your installed CycleCloud server:
```
$ cyclecloud initialize
```
The [CycleCloud setup documentation](https://docs.cyclecomputing.com/installation-guide-v6.6.0/install_cli#CLI_Configuration) describes this step in more detail.

### Configuring POGO CLI

Pogo (Put Object Get Object) is a data transfer CLI. Instructions for setting it up is described in the [pogo docs](https://docs.cyclecomputing.com/administrator-guide-v6.6.0/pogo/pogo_config).

Here's a quicker way of creating a pogo config for the blob storage account configured when you set up your Azure subscription in CycleCloud.

1. Fetch the storage account (or "locker") that is associated with the azure account:

```
$  cyclecloud locker list
azure-storage (az://cyclecloudapp/cyclecloud)
```

2. Edit the cyclecloud config file `~cycle/config.ini`, which was created by the `cyclecloud initialize` commmand.

Add the following section in `~cycle/config.ini`, replacing the subscription_id, tenant_id, application_id and application_secret with your Azure AD Service Principal.

The application_secret is your SP password.

Replace `az://cyclecloudapp/cyclecloud` with your locker URI.

```
[pogo azure-storage]
type = az
subscription_id = XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
tenant_id = XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
application_id = XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
application_secret = XXXXXXXXXX
matches=az://cyclecloudapp/cyclecloud
```

### Uploading the project files into the storage account:

Note the name of the storage locker, in the example below it is `azure-storage`:
```
$  cyclecloud locker list
azure-storage (az://cyclecloudapp/cyclecloud)
```

From the directory where the `project.ini` file exists (the root of the git repo), upload the project:
```
$ cyclecloud project upload azure-storage
Uploading to az://cyclecloudapp/cyclecloud/projects/CompChem/1.0.0 (100%)
Sync completed!
```

### Import the cluster template

```
$ cyclecloud import_cluster CompChem-Template -c "ComputationalChemistry" -t -f template/compchem.sge.template.txt
Importing cluster ComputationalChemistry and creating cluster CompChem-Template as a template....
------------------------------
CompChem-Template : *template*
------------------------------
Keypair:
Cluster nodes:
    login:  off
    master: off
Total nodes: 2
```


### Create and start the cluster

Log into your CycleCloud server's web interface, create a new cluster using the "+" button on the bottom left hand corner. You should see the CompChem cluster as one of the options for a new cluster.








