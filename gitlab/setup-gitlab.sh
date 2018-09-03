#!/bin/bash

docker run \
    -d -v ../gitlab/data:/var/opt/gitlab \
    -v ../gitlab/logs:/var/log/gitlab \
    -v ../gitlab/config:/etc/gitlab \
    -p 1022:22 \
    -p 1080:80 \
    -p 10443:443 \
    --net ci-cd-docker-net --ip='172.18.0.2' \
    --name gitlab \
    gitlab/gitlab-ce:latest
