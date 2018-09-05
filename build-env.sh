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
    if [ -f /etc/redhat-release ]; then
        platform='CentOS'
    elif [ -f /etc/lsb-release ]; then
        platform="Ubuntu"
    fi
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='MACOSX'
fi

##
## We make sure that the system is up to date
##
echo "#################################################"
echo "Updating the platform"
echo "#################################################"
if [[ "$platform" == 'Ubuntu' ]]; then
    sudo apt-get -y update
    sudo apt-get -y upgrade 
elif [[ "$platform" == 'Darwin' ]]; then
    brew update
elif [[ "$platform" == 'CentOS' ]]; then
    sudo yum update -y 
    sudo yum upgrade -y
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

##
## Permission issues with consul - TO BE INVESTIGATED
##
chmod -R 777 docker_volumes/consul/*

curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/jenkins.tgz --output jenkins.tgz
tar zxf jenkins.tgz -C docker_volumes

curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/gitlab.tgz --output gitlab.tgz
tar zxf gitlab.tgz -C docker_volumes
sudo setfacl -bR docker_volumes/gitlab

##
## Check if the docker network ci-cd-docker-net exists. If not, we create it
## we check for a docker network called ci-cd-docker-net. The subnet use will be 172.18.0.0/16
##

output=""
output=`docker network ls  | grep ci-cd-docker-net`

if [[ "$output" == '' ]]; then
   echo "creating docker network"
   sudo docker network create --subnet=172.18.0.0/16 ci-cd-docker-net
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
if [[ "$unamestr" == 'Linux' ]]; then
   sh jenkins/setup-jenkins.sh $PWD /usr/bin/docker
elif [[ "$unamestr" == 'Darwin' ]]; then
   sh jenkins/setup-jenkins.sh $PWD /usr/local/bin/docker
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


if [[ "$unamestr" == 'Linux' ]]; then
    #echo "Linux deployment is not automated yet, please set it up yourself: https://docs.okd.io/latest/minishift/using/run-against-an-existing-machine.html#configuring-existing-remote-machine"
    mkdir minishift 
    wget https://github.com/minishift/minishift/releases/download/v1.23.0/minishift-1.23.0-linux-amd64.tgz
    tar zxf minishift-1.23.0-linux-amd64.tgz -C minishift/
    sudo mv minishift/minishift-1.23.0-linux-amd64/minishift /usr/local/bin/
    sudo firewall-cmd --permanent --add-port 2376/tcp --add-port 8443/tcp --add-port 80/tcp
    dockernet=`sudo docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge`
    sudo firewall-cmd --permanent --new-zone minishift
    sudo firewall-cmd --permanent --zone minishift --add-source $dockernet
    sudo firewall-cmd --permanent --zone minishift --add-port 53/udp --add-port 8053/udp
    sudo firewall-cmd --reload
    read -p 'Your VM IP: ' serverip
    minishift addons install --defaults
    minishift addons enable admin-user
    minishift start --vm-driver generic --remote-ipaddress $serverip --remote-ssh-user $USER --remote-ssh-key $HOME/.ssh/id_rsa --memory 4Gb
    minishift addon apply admin-user
elif [[ "$platform" == 'MACOSX' ]]; then
    echo "Installing Minishift on a MACOSX platform" 
    brew cask install minishift

    minishift addons install --defaults
    minishift addons enable admin-user
    minishift addon apply admin-user
    minishift start
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
