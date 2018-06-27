#!/bin/sh

docker run \
    --name consul \
    -d -p 8301:8301 -p 8302:8302 -p 8400:8400 -p 8500:8500 -p 8600:8600/udp \
    -v $1/consul/:/consul/data consul \
    consul agent -server -bind=127.0.0.1 -bootstrap -data-dir=/consul/data -client 0.0.0.0

