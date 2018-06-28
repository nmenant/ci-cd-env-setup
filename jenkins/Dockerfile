# In general, you should always provide exact version (eg. 2.89.3) 
# rather than some more general tag (latest/lts)
FROM jenkins/jenkins:lts

USER root

#ARG HOST_DOCKER_GROUP_ID

# Create 'docker' group with provided group ID 
# and add 'jenkins' user to it
#RUN groupadd docker -g ${HOST_DOCKER_GROUP_ID} && \  
#    usermod -a -G docker jenkins

RUN apt-get update && \  
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
	jq \
	python \
	python-pip \
	wget \ 
	git \
	python-setuptools \
	python-requests && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce && \
    apt-get clean


RUN usermod -a -G root jenkins

RUN usermod -aG docker jenkins

# Run Jenkins as dedicated non-root user
USER jenkins 
