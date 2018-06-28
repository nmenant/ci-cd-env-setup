SETUP CI CD ENV
===============

This repo will automatically setup a "CI/CD" environment on the laptop with: Gitlab, Jenkins, Consul and some default pipeline/examples

Requirements: 

* Docker must be installed
* git-lfs : https://help.github.com/articles/installing-git-large-file-storage/ (git lfs track "*.pack")
* minishift is expected to start with an IP of 192.168.64.2
* gitlab is expected to run on 172.17.0.2
* jenkins is expected to run on 172.17.0.3


Start minishift: 
****************

minishift start

minishift oc-env 





