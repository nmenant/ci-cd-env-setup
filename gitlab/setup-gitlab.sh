#!/bin/bash

docker run \
    -d -v $1/gitlab/data:/var/opt/gitlab \
    -v $1/gitlab/logs:/var/log/gitlab \
    -v $1/gitlab/config:/etc/gitlab \
    -p 1022:22 \
    -p 1080:80 \
    -p 10443:443 \
    --name gitlab \
    gitlab/gitlab-ce:latest
