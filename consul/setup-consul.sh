#!/bin/bash

docker run \
    --name consul \
    -d --net ci-cd-docker-net --ip='172.18.0.4' -p 8301:8301 -p 8302:8302 -p 8400:8400 \
    -p 8500:8500 -p 8600:8600/udp \
    -v consul/:/consul/data consul \
    consul agent -server -bind=127.0.0.1 -bootstrap -data-dir=/consul/data -client 0.0.0.0

