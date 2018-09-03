#!/bin/bash

## We consider two scenarios: 
## 1- you use a MAC and want to install it on your laptop
##      If you use a MAC, we consider that you already have brew and docker installed
## 2- you want to use a VM to do this and use Ubuntu 16.04 or later. 
##      If you use a Ubuntu VM, we will try to install everything. 
## Any other deployment is not supported today
## 

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='Linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='MACOSX'
fi

##
## We make sure that the system is up to date
##
echo "#################################################"
echo "Updating the platform"
echo "#################################################"
if [[ "$platform" == 'Linux' ]]; then
    sudo apt-get -y update
    sudo apt-get -y upgrade 
    ##
    ## software-properties-common is needed to have add-apt-repository
    ##
    sudo apt install -y software-properties-common net-tools firewalld
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    apt-cache policy docker-ce
    sudo apt-get install -y docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo systemctl start firewalld
    sudo systemctl enable firewalld 
elif [[ "$platform" == 'Darwin' ]]; then
   brew update
fi

##
## Retrieve the containers' volumes from AWS S3
##

echo "#################################################"
echo "Retrieving the containers volumes"
echo "#################################################"

mkdir docker_volumes
curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/consul.tgz --output consul.tgz
tar zxf consul.tgz -C docker_volumes

curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/jenkins.tgz --output jenkins.tgz
tar zxf jenkins.tgz docker_volumes

curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/gitlab.tgz --output gitlab.tgz
tar zxf gitlab.tgz docker_volumes

##
## Check if the docker network ci-cd-docker-net exists. If not, we create it
## we check for a docker network called ci-cd-docker-net. The subnet use will be 172.18.0.0/16
##

output=""
output=`docker network ls  | grep ci-cd-docker-net`

if [[ "$output" == '' ]]; then
   echo "creating docker network"
   docker network create --subnet=172.18.0.0/16 ci-cd-docker-net
fi

##
## SETUP MINISHIFT
##

##
## Need to identify the platform to make sure we can install Minishift
## installation guide is here: ## update accordingly:  https://docs.okd.io/latest/minishift/getting-started/installing.html
##

echo "#################################################"
echo "SETTING UP MINISHIFT"
echo "#################################################"


if [[ "$platform" == 'Linux' ]]; then
    #echo "Linux deployment is not automated yet, please set it up yourself: https://docs.okd.io/latest/minishift/using/run-against-an-existing-machine.html#configuring-existing-remote-machine"
    mkdir minishift 
    wget https://github.com/minishift/minishift/releases/download/v1.23.0/minishift-1.23.0-linux-amd64.tgz
    tar zxf minishift-1.23.0-linux-amd64.tgz -C minishift/
    mv minishift/minishift-1.23.0-linux-amd64/minishift /usr/local/bin/
    sudo firewall-cmd --permanent --add-port 2376/tcp --add-port 8443/tcp --add-port 80/tcp
    dockernet=`sudo docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge`
    sudo firewall-cmd --permanent --new-zone minishift
    sudo firewall-cmd --permanent --zone minishift --add-source $dockernet
    sudo firewall-cmd --permanent --zone minishift --add-port 53/udp --add-port 8053/udp
    sudo firewall-cmd --reload
    read -p 'VM IP: ' serverip
    minishift start --vm-driver generic --remote-ipaddress $serverip --remote-ssh-user $USER --remote-ssh-key $HOME/.ssh/id_rsa
elif [[ "$platform" == 'MACOSX' ]]; then
    echo "Installing Minishift on a MACOSX platform" 
    brew cask install minishift

    minishift addons install --defaults
    minishift addons enable admin-user
    minishift addon apply admin-user
    minishift start
fi


echo "#################################################"
echo "CONTAINER: SETTING UP GITLAB"
echo "#################################################"

## Launch Gitlab containers
docker rm gitlab
sh gitlab/setup-gitlab.sh $PWD

echo "#################################################"
echo "CONTAINER: SETTING UP JENKINS"
echo "#################################################"
## Launch Jenkins containers
docker rm jenkins
docker rmi jenkins-with-python-docker
if [[ "$platform" == 'Linux' ]]; then
   sh jenkins/setup-jenkins.sh $PWD /usr/bin/docker
elif [[ "$platform" == 'MACOSX' ]]; then
   sh jenkins/setup-jenkins.sh $PWD /usr/local/bin/docker
fi



echo "#################################################"
echo "CONTAINER: SETTING UP CONSUL"
echo "#################################################"
## Launch consul container
docker rm consul
sh consul/setup-consul.sh $PWD

##
## SETUP CONSUL
## We need to setup consul Kv properly so that everything can talk to Minshift and BIG-IP(s)
##
