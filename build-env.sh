#!/bin/sh
# Static IP for containers can only be done in a user defined network so you'll need to create it first
# docker network create --subnet=172.18.0.0/16 mydockernetwork

CONTAINERS_VOL="/Users/menant/projects/containers_vol"

## Setup Gitlab
docker rm gitlab
sh gitlab/setup-gitlab.sh $CONTAINERS_VOL

## Setup Jenkins
docker rm jenkins
docker rmi jenkins-with-python-docker
sh jenkins/setup-jenkins.sh $CONTAINERS_VOL

## Setup Consul
docker rm consul
sh consul/setup-consul.sh $CONTAINERS_VOL

## Setup minishift

## to install minishift on MACOS X, if you use another distro, check this link and
## update accordingly:  https://docs.okd.io/latest/minishift/getting-started/installing.html
brew cask install minishift

minishift addons install --defaults

minishift addons enable admin-user

minishift addon apply admin-user

