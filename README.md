SETUP CI CD ENV
===============

!!WARNING!! This is work in progress. Those scripts will works but the docker volumes have not been
    transfered YET on this repo

This repo will automatically setup a "CI/CD" environment on the laptop with: Gitlab, Jenkins, Consul, Minishift and some default pipeline/examples

Requirements
------------

* This solution is created for MAC OS X or  2xVM running Ubuntu or 2xVM Running Centos. 
* AS3 must be installed on the BIG-IP devices used <https://github.com/F5Networks/f5-appsvcs-extension/releases>

Ubuntu/CentOs specific requirements:

* The user must be allowed to do sudo commands without password (use *sudo visudo* and add a line like *USERNAME ALL=(ALL)       NOPASSWD: ALL*)                         (<https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file-on-ubuntu-and-centos>)
* You must have created a ssh key and use ssh-copy-id locally on the IP of the device (not localhost)
* Disable SELinux (a reboot is required after)

Prepare the Ubuntu platforms
----------------------------

    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt install -y git software-properties-common net-tools firewalld wget
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    apt-cache policy docker-ce
    sudo apt-get install -y docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker
    # Allow the user to run docker command without sudo - needed for Minishift
    sudo groupadd docker
    sudo usermod -aG docker $USER

Reboot your VM. it's required to be able to run docker command without sudo. Changes won't be taken
into account until a restart is done.

Make sure that docker and firewalld are runnning:

    sudo systemctl status docker
    sudo systemctl status firewalld

Prepare the CentOs platforms
----------------------------

You'll need to do the following first:

* Disable Selinux (/etc/selinux/config to be updated)
* Reboot the instance

then:

    sudo yum update -y
    sudo yum upgrade -y
    sudo yum install -y git docker net-tools wget firewalld
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    # Allow the user to run docker command without sudo - needed for Minishift
    sudo groupadd docker
    sudo usermod -aG docker $USER

Reboot your VM. it's required to be able to run docker command without sudo. Changes won't be taken
into account until a restart is done.

Make sure that docker and firewalld are runnning:

    sudo systemctl status docker
    sudo systemctl status firewalld

Installing the env - pipeline tools
-----------------------------------

On one of the VM, we will install all the pipeline tools:

* Gitlab
* Jenkins
* Consul

To ihstall the pipeline tools, retrieve the github repository:

    git clone https://github.com/nmenant/ci-cd-env-setup
    cd ci-cd-env-setup

Run *build-env.sh pipeline* to install the different components:

* Update the system
* A user-defined network (ci-cd-docker-net) in docker will be created (172.18.0.0/16)
* Gitlab will run on 172.18.0.2
* Jenkins will run on 172.18.0.3
* Consul will run on 172.18.0.4

Everything will be started at the same time

Installing the env - minishift
-----------------------------------

On this VM, we will install minishift

To ihstall minishift, retrieve the github repository:

    git clone https://github.com/nmenant/ci-cd-env-setup
    cd ci-cd-env-setup

Run *build-env.sh minishift* to install minishift:

* Update the system
* Install Minishift in the VM. You'll be requested for the IP of the VM

minishift will be started at the same time. Its GUI will be available on <https://IP:8443/console>

login by default with:

* Login: dev
* Password: dev

Start the environment
---------------------

Run *start-env.sh* to start the environment.

Gitlab will be available at: <http://127.0.0.1:1080/> (admin access- root, password: Pa55w0rd)
Jenkins will be available at: <http://127.0.0.1:1180/> (admin access- login: admin, password: Pa55w0rd)
Consul KV will be available at: <http://172.0.0.1:8500/>

to identify the IP used by minishift, run the command *minishift ip*

Update Consul
-------------

Consul can be used to store infrastructure information leveraged by Jenkins. By default it contains the following default KV:

    GET http://127.0.0.1:8500/v1/kv/?keys

    [
    "Minishift/minishift_ip",
    "Minishift/minishift_port",
    "Minishift/minishift_token",
    "nicolas/ADC-Services/cluster-nicolas/cluster_credentials",
    "nicolas/ADC-Services/cluster-nicolas/cluster_ips"
    ]

They are used in the 2 default jenkins pipeline. You still need to update a few variables based on your env:

* you need to update minishift_ip with the IP of your minishift cluster. You can get this information with the command *minishift ip*
* you need to update minishift_token with the token you'll get by creating a service account allowed to do API calls in your minishift project (<https://docs.openshift.com/container-platform/3.10/rest_api/index.html> - right now there is a bug in the doc, it's *oc policy add-role-to-user admin system:serviceaccount:test:robot* and not *oc policy add-role-to-user admin system:serviceaccounts:test:robot*)
* you need to update cluster_ips with the cluster of your BIG-IPs. You can put a single IP for a standalone deployment
* if you changed the default credentials of your BIG-IP, you'll need to also update cluster_credentials

Update those values accordingly to your infrastructure

    To check a key value:
    GET http://127.0.0.1:8500/v1/kv/nicolas/ADC-Services/cluster-nicolas/cluster_ips

    To update the value of a key:
    PUT http://127.0.0.1:8500/v1/kv/nicolas/ADC-Services/cluster-nicolas/cluster_ips

    192.168.143.13
