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
    sudo apt install -y software-properties-common
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    apt-cache policy docker-ce
    sudo apt-get install -y docker-ce 
elif [[ "$platform" == 'Darwin' ]]; then
   brew update
fi

##
## Retrieve the containers' volumes from AWS S3
##

echo "#################################################"
echo "Retrieving the containers volumes"
echo "#################################################"

curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/consul.tgz --output consul.tgz
tar --warning=no-unknown-keyword zxf consul.tgz

curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/jenkins.tgz --output jenkins.tgz
tar --warning=no-unknown-keyword zxf jenkins.tgz

curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/gitlab.tgz --output gitlab.tgz
tar --warning=no-unknown-keyword zxf gitlab.tgz

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


echo "#################################################"
echo "CONTAINER: SETTING UP GITLAB"
echo "#################################################"

## Setup Gitlab
docker rm gitlab
sh gitlab/setup-gitlab.sh 

echo "#################################################"
echo "CONTAINER: SETTING UP JENKINS"
echo "#################################################"
## Setup Jenkins
docker rm jenkins
docker rmi jenkins-with-python-docker
sh jenkins/setup-jenkins.sh 

echo "#################################################"
echo "CONTAINER: SETTING UP CONSUL"
echo "#################################################"
## Setup Consul
docker rm consul
sh consul/setup-consul.sh $CONTAINERS_VOL

##
## SETUP MINISHIFT
##

##
## Need to identify the platform to make sure we can install Minishift
## installation guide is here: ## update accordingly:  https://docs.okd.io/latest/minishift/getting-started/installing.html
##

echo "#################################################"
echo "CONTAINER: SETTING UP MINISHIFT"
echo "#################################################"


if [[ "$platform" == 'Linux' ]]; then
   echo "Installing Minishift on a Linux platform"
   curl https://github.com/minishift/minishift/releases/download/v1.23.0/minishift-1.23.0-linux-amd64.tgz --output minishift.tgz
elif [[ "$platform" == 'MACOSX' ]]; then
   echo "Installing Minishift on a MACOSX platform" 
   brew cask install minishift
fi


#minishift addons install --defaults

#minishift addons enable admin-user

#minishift addon apply admin-user

