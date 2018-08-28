#!/bin/sh

docker build -t jenkins-with-python-docker jenkins/

docker run \
    -d -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/local/bin/docker:/usr/bin/docker \
    -v $1/jenkins:/var/jenkins_home \
    -p 1180:8080 \
    -p 11000:50000 \
    --ip='172.17.0.3' \
    --name jenkins \
    jenkins-with-python-docker


