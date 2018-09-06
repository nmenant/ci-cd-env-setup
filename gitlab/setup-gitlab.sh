#!/bin/bash

##
## We extract from the archive name the gitlab version (if we don't run the same version, it will fail)
##

gitlab_version=`echo $2 | cut -d'_' -f 5`

docker run \
    -d -v $1/docker_volumes/gitlab/data:/var/opt/gitlab \
    -v $1/docker_volumes/gitlab/logs:/var/log/gitlab \
    -v $1/docker_volumes/gitlab/config:/etc/gitlab \
    -p 1022:22 \
    -p 1080:80 \
    -p 10443:443 \
    --net ci-cd-docker-net --ip='172.18.0.2' \
    --name gitlab \
    gitlab/gitlab-ce:$gitlab_version-ce.0

