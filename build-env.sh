#!/bin/bash

## We consider two scenarios: 
## 1- you use a MAC and want to install it on your laptop
##      If you use a MAC, we consider that you already have brew and docker installed
## 2- you want to use a VM to do this, use Centos 7
##      Follow the README guide to check the pre requisites
## Any other deployment is not supported today
## 

function error_syntax () {
    echo "#################################"
    echo "Syntax for build-env.sh: "
    echo "  ./build-env.sh minishift: will install minishift and update consul accordingly"
    echo "  ./build-env.sh pipeline: will install gitlab, jenkins, consul"
    echo "You cannot run minishift and pipeline on the same VM (except if set this up on your MAC)"
    echo "#################################"
}

function install_minishift() {
    ##
    ## Need to identify the platform to make sure we can install Minishift
    ## installation guide is here: ## update accordingly:  https://docs.okd.io/latest/minishift/getting-started/installing.html
    ##

    echo "#################################################"
    echo "SETTING UP MINISHIFT"
    echo "#################################################"

    read -p 'Your VM IP: ' serverip
    read -p 'Consul IP: ' consulip
    read -p 'BIG-IP IP: ' bigipip
    read -p 'BIG-IP Admin Port': bigipport
    if [[ "$unamestr" == 'Linux' ]]; then
        #echo "Linux deployment is not automated yet, please set it up yourself: https://docs.okd.io/latest/minishift/using/run-against-an-existing-machine.html#configuring-existing-remote-machine"
        mkdir minishift 
        wget https://github.com/minishift/minishift/releases/download/v1.23.0/minishift-1.23.0-linux-amd64.tgz
        tar zxf minishift-1.23.0-linux-amd64.tgz -C minishift/
        sudo mv minishift/minishift-1.23.0-linux-amd64/minishift /usr/local/bin/
        sudo firewall-cmd --permanent --add-port 2376/tcp --add-port 8443/tcp --add-port 80/tcp
        dockernet=`sudo docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge`
        sudo firewall-cmd --permanent --new-zone minishift
        sudo firewall-cmd --permanent --zone minishift --add-source $dockernet
        sudo firewall-cmd --permanent --zone minishift --add-port 53/udp --add-port 8053/udp
        sudo firewall-cmd --reload
        minishift addons install --defaults
        minishift addons enable admin-user
        minishift start --vm-driver generic --remote-ipaddress $serverip --remote-ssh-user $USER --remote-ssh-key $HOME/.ssh/id_rsa --memory 4Gb
        minishift addon apply admin-user
        rm minishift-1.23.0-linux-amd64.tgz
    elif [[ "$platform" == 'MACOSX' ]]; then
        echo "Installing Minishift on a MACOSX platform" 
        brew cask install minishift

        minishift addons install --defaults
        minishift addons enable admin-user
        minishift addon apply admin-user
        minishift start
    fi

    ##
    ## We setup minishift and create a user for API interaction
    ## 
    echo "#################################################"
    echo "CONFIGURING PROJECT IN MINISHIFT"
    echo "#################################################"
    eval $(minishift oc-env)
    oc login -u dev -p dev
    oc new-project tenanta-dev
    oc create serviceaccount robot
    oc policy add-role-to-user admin system:serviceaccount:tenanta-dev:robot
    oc serviceaccounts get-token robot > robot-token.json
    echo "Robot API Token:"
    cat robot-token.json
    ##
    ## We update Consul based on our Minishift Setup
    ## 
    echo "#################################################"
    echo "CONFIGURING CONSUL - Update Minishift keys"
    echo "#################################################"
    curl -X PUT -d @robot-token.json http://$consulip:8500/v1/kv/Minishift/minishift_token 
    curl -X PUT -d $serverip  http://$consulip:8500/v1/kv/Minishift/minishift_ip 

    ##
    ## We update Consul based on our Minishift Setup
    ## 
    echo "#################################################"
    echo "CONFIGURING CONSUL - Update BIG-IP IP Address/port"
    echo "#################################################"
    curl -X PUT -d $bigipip http://$consulip:8500/v1/kv/tenanta/ADC-Services/cluster-nicolas/cluster_ips
    curl -X PUT -d $bigipport http://$consulip:8500/v1/kv/tenanta/ADC-Services/cluster-nicolas/cluster_port
}

function install_pipeline() 
{
    echo "##############INSTALLING PIPELINE###################"
    gitlab_archive='1538386497_2018_10_01_11.2.3_gitlab_backup.tar'

    ##
    ## Retrieve the containers' volumes/backups from AWS S3
    ##

    echo "#################################################"
    echo "Retrieving the containers volumes/Backups"
    echo "#################################################"

    mkdir docker_volumes
    curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/consul.tgz --output consul.tgz
    tar zxf consul.tgz -C docker_volumes

    ##
    ## Permission issues with consul - TO BE INVESTIGATED
    ##
    chmod -R 777 docker_volumes/consul/*

    curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/jenkins.tgz --output jenkins.tgz
    tar zxf jenkins.tgz -C docker_volumes

    curl https://s3.eu-west-3.amazonaws.com/nmenant-public/CI-CD+docker-volumes/$gitlab_archive --output $gitlab_archive
    mkdir docker_volumes/gitlab
    mkdir docker_volumes/gitlab/data
    mkdir docker_volumes/gitlab/logs
    mkdir docker_volumes/gitlab/config

    ##
    ## Check if the docker network ci-cd-docker-net exists. If not, we create it
    ## we check for a docker network called ci-cd-docker-net. The subnet use will be 172.18.0.0/16
    ##

    output=""
    output=`docker network ls  | grep ci-cd-docker-net`

    if [[ "$output" == '' ]]; then
       echo "creating docker network"
       sudo docker network create --subnet=172.18.0.0/16 ci-cd-docker-net
    fi

    echo "#################################################"
    echo "CONTAINER: SETTING UP GITLAB"
    echo "#################################################"

    ## Launch Gitlab container
    docker rm gitlab
    sh gitlab/setup-gitlab.sh $PWD $gitlab_archive 

    # Give time for the gitlab container to start
    sleep 30

    # We start working on restoring the archive 
    # https://gitlab.com/gitlab-org/gitlab-ce/issues/14740
    # https://docs.gitlab.com/ee/raketasks/backup_restore.html
    echo "#################################################"
    echo "Gitlab - Reconfigure GITLAB container"
    echo "#################################################"
    docker exec gitlab gitlab-ctl reconfigure

    echo "#################################################"
    echo "Gitlab - Checking state of GITLAB container"
    echo "#################################################"
    docker exec gitlab gitlab-rake gitlab:check SANITIZE=true

    # restore backup now for gitlab container
    echo "#################################################"
    echo "Gitlab - loading archive of GITLAB container"
    echo "#################################################"
    docker cp $gitlab_archive gitlab:/var/opt/gitlab/backups
    docker exec gitlab gitlab-ctl stop unicorn
    docker exec gitlab gitlab-ctl stop sidekiq
    docker exec gitlab chmod -R 775 /var/opt/gitlab/backups

    archive_name=`echo $gitlab_archive | sed s/_gitlab_backup.tar//g`
    # note -it flag so you can respond to questions that restore script asks!
    docker exec -it gitlab gitlab-rake gitlab:backup:restore BACKUP=$archive_name
    echo "#################################################"
    echo "Gitlab - restarting GITLAB container...."
    echo "#################################################"
    docker exec gitlab gitlab-ctl start

    echo "#################################################"
    echo "Gitlab - Checking state of GITLAB container - FINAL"
    echo "#################################################"
    docker exec gitlab gitlab-rake gitlab:check SANITIZE=true

    echo "#################################################"
    echo "CONTAINER: SETTING UP JENKINS"
    echo "#################################################"
    ## Launch Jenkins containers
    docker rm jenkins
    docker rmi jenkins-with-python-docker
    if [[ "$unamestr" == 'Linux' ]]; then
       sh jenkins/setup-jenkins.sh $PWD /usr/bin/docker
    elif [[ "$unamestr" == 'Darwin' ]]; then
       sh jenkins/setup-jenkins.sh $PWD /usr/local/bin/docker
    fi

    echo "#################################################"
    echo "CONTAINER: SETTING UP CONSUL"
    echo "#################################################"
    ## Launch consul container
    docker rm consul
    sh consul/setup-consul.sh $PWD

    echo "#################################################"
    echo "CONTAINER: Cleaning up folder"
    echo "#################################################"
    rm jenkins.tgz
    rm consul.tgz
    rm $gitlab_archive

}

if [ "$#" -ne 1 ]; then
    error_syntax
    exit -1
fi

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    if [ -f /etc/redhat-release ]; then
        platform='CentOS'
    elif [ -f /etc/lsb-release ]; then
        platform="Ubuntu"
    fi
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='MACOSX'
fi

if  [ "$1" == "minishift" ] | [ "$1" == "pipeline" ]; then
    ##
    ## We make sure that the system is up to date
    ##
    echo "#################################################"
    echo "Updating the platform"
    echo "#################################################"
    if [[ "$platform" == 'Ubuntu' ]]; then
        echo "Ubuntu is not support, Only CentOs is supported as a platform"
        echo -1
    elif [[ "$platform" == 'Darwin' ]]; then
        brew update
    elif [[ "$platform" == 'CentOS' ]]; then
        sudo yum update -y 
        sudo yum upgrade -y
    fi
fi

if  [ "$1" == "minishift" ]; then
        install_minishift
elif [ "$1" == "pipeline" ] ; then
        install_pipeline
else
        error_syntax
fi

