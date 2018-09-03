#!/bin/bash


## Start Gitlab
docker stop gitlab

## Start Jenkins
docker stop jenkins

## Start Consul
docker stop consul

## Stop minishift
minishift stop
