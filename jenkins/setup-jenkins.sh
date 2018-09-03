#!/bin/bash

docker build -t jenkins-with-python-docker jenkins/

docker run \
    -d -v /var/run/docker.sock:/var/run/docker.sock \
    -v $2:/usr/bin/docker \
    -v $1/docker_volumes/jenkins:/var/jenkins_home \
    -p 1180:8080 \
    -p 11000:50000 \
    --net ci-cd-docker-net --ip='172.18.0.3' \
    --name jenkins \
    jenkins-with-python-docker


