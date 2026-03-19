# Testsuite introduction

# Setting up Testsuite

## Setting up Testsuite from scratch

## Bootstrapping Testsuite from an existing cluster

# Running Testsuite on prem

# Running Testsuite in the cloud

via the scripts from the [deployment](https://github.com/hpc-gridware/deployments/tree/main) repository

## GCP

###  basis setup in GCP
https://console.cloud.google.com

#### install gcloud
```shell
wget https://sdk.cloud.google.com/ -O gcloud_installer.sh
bash gcloud_installer.sh  --disable-prompts
```

#### install terraform

```shell
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
terraform init
```

#### login to gcloud

```shell
gcloud auth application-default login
```

### checkout the deployment repository

```shell
git clone https://github.com/hpc-gridware/deployments.git
cd deployments
```



### set up a head node

```shell
cd terraform/gcp/gcp_headnode
```

Edit `terraform.tfvars`, fill in the attributes (except `gce_ssh_pub_key_file` and `key_name`).
Optionally `copy_user_pub_key` and `os_image`.

Make sure to use a current version of the `os_image`.  
The name of an `os_image` can be retrieved from the GCP console, `Images`, use the `Filter` to find specific images.

On the command line the `gcloud` command can be used to find the image name.  
In case we want to use a Ubuntu 24.04 image, the following command can be used to find the image name:

```shell
gcloud compute images list --project=ubuntu-os-cloud --filter="name=ubuntu-2404-noble-amd64-" --format="value(name)"
```

```shell
terraform apply
```

#### Connecting to the head node

##### with ssh public key installed

To make the head node accessible by name,
copy the external ip address of the gridware-headnode VM from the GCP console and add it to `/etc/hosts`, e.g.:
```
34.172.105.223  gridware-headnode
```

If `copy_user_pub_key` was set to true in `terraform.tfvars` then you can connect to the head node with the ssh:
```shell
ssh sgetest@gridware-headnode
```


##### without ssh public key installed
Connect to the head node by using the SSH button in the VM instances view in the Web Console.

Or use gcloud (get the command line from SSH button -> gcloud ..., e.g.
```shell
gcloud compute ssh --zone "us-central1-a" "gridware-headnode" --project "peformancetests"
```

#### update the head node

```shell
~$ ssh root@localhost
~# apt update
~# apt dist-upgrade
~# apt autoremove
~# apt clean
```

If necessary (e.g. new kernel installed) then
```shell
~# reboot
```

#### optionally: work in a vnc session

Start a vnc server on the head node

```shell
ssh sgetest@gridware-headnode
vncserver -geometry 1920x1080 :9
```

Connect to the vnc server
    
```shell
vncviewer -via sgetest@gridware-headnode localhost:9
```


### install a cluster

```shell
cd terraform/gcp
```

Edit `terraform.tfvars`, fill in the attributes (except `gce_ssh_pub_key_file` and `key_name`).

```shell
terraform apply
```

Wait for the cluster to be set up:
* when the master-instance is up, `/shared/ocs` directory will appear and be populated
* when available source `/shared/ocs/default/common/settings.sh` to set up the environment
* call `qconf -sel | wc -l` until the number of nodes is what you expect (number of execution nodes [+ 1 master node])

### test ssh connections

After the installation passwordless ssh from the head node to the cluster nodes should work,
both as the `sgetest` user and as the `root` user.

Make sure that old ssh keys are not present on the cluster nodes:
```bash
rm .ssh/known_hosts
```

Try to connect to a few hosts:
```bash
ssh sgetest@master-instance
ssh root@master-instance
ssh sgetest@execution-0
ssh root@execution-0
```

### bootstrap testsuite

#### checkout code

```shell
mkdir master
cd master
git clone https://github.com/hpc-gridware/testsuite.git
git clone https://github.com/hpc-gridware/clusterscheduler.git
```

```shell
cd testsuite/src
cp templates/bootstrap_gcp.txt bootstrap.txt
```

All the default configuration options in `bootstrap.txt` should be correct.
If you want testsuite to send email then edit `bootstrap.txt`, uncommment `mailx_host` line,
uncomment the `report_mail_to` line and enter your email address.

Start the testsuite bootstrapping:

```shell
mkdir CONFIG RESULTS
expect check.exp file CONFIG/cluster.conf bootstrap bootstrap.txt no_local_config
```

Testsuite will bootstrap itself from the existing cluster and startup into its main menu.

## Fetching Test Results

cd to a directory where you want to store the results.

```shell
rsync -avz sgetest@master-instance:/shared/testsuite/RESULTS/ .
```

## Regenerating Test Results and Overview pages

The performance test results are stored in the RESULTS directory, in a sub-directory `cluster/protocols/throughput`.
For every test run a new sub-directory is created,
its name being built as `<version>_<num_hosts>_<num_jobs>_<features>_<datetime>`,
e.g., `GCS_9.0.11_170226-1053_256_50000_none_2026-03-16-09-40`.
In this directory, there are
* a data file per test scenario, e.g., `disabled.tsd`, `enabled.tsd`, ...
* a sub-directory per test scenario, e.g., `disabled`, `enabled`, ...

The test scenario subdirectories contain a HTML report file, `index.html`,
referencing charts and data files as well as a copy of the `sge_qmaster` messages file.

Testsuite allows re-creating the HTML report (e.g., when the output format was changed in the code)
and generating overview pages for all the test scenarios and for all the tests runs.

### Recreating the HTML report

In the testsuite interactive TCL shell (menu item 60), type
```tcl
analyse_dump_data_file <path_to_data_file> 1
```

### Create / Update Overview pages

#### Create overview pages for all test scenarios of one run

In the testsuite interactive TCL shell (menu item 60), type
```tcl
generate_per_run_overview <path_to_data_file>
```

#### Create overview pages for all test scenarios of all runs

In the testsuite interactive TCL shell (menu item 60), type
```tcl
generate_multiple_run_overview <path_to_data_file> <num_hosts> <num_jobs>
```

The number of hosts and jobs has to be specified (e.g., 256 hosts and 50.000 jobs for our reference runs in GCP),
to filter runs with comparable data.

# Troubleshooting

## High CPU load when running testsuite and Copilot is installed for vim

Testsuite is calling vim when doing configuration changes.   
If Copilot is enabled for vim, you might see high load on testsuite hosts and `node` being shown
consuming a lot of CPU time.

To fix this issue disable Copilot by default in the `.vimrc` and enable it when using `vim` interactively.

Add to the `.vimrc` the line:
```shell
autocmd VimEnter * Copilot disable
```

When running vim interactively type `:Copilot enable` to enable Copilot.
