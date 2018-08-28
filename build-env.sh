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

