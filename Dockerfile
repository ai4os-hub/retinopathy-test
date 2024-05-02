# Dockerfile may have following Arguments: tag, pyVer, branch
# tag - tag for the Base image, (e.g. 1.10.0-py3 for tensorflow)
# branch - user repository branch to clone (default: master, other option: test)

ARG tag=1.12.0-py36

# Base image, e.g. tensorflow/tensorflow:1.12.0-py3
FROM ai4oshub/tensorflow:${tag}

LABEL maintainer='HMGU'
LABEL version='0.1.0'
# Retinopathy classification using Tensorflow
# What user branch to clone (!)
ARG branch=main

# Install ubuntu updates and python related stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
         git \
         curl \
         wget \
         gcc \
         libgl1 \
         libsm6 \
         libxext6 \
         libxrender1 \
         python3-setuptools \
         python3-pip \
         python3-dev \
         python3-wheel \
         unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* 

# Upgrade pip
RUN pip3 install --upgrade pip setuptools wheel && \
    python --version && \
    pip --version

# install rclone
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENV RCLONE_CONFIG=/srv/.rclone/rclone.conf

# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

# Initialization scripts
# deep-start can install JupyterLab or VSCode if requested
RUN git clone https://github.com/ai4os/deep-start /srv/.deep-start && \
    ln -s /srv/.deep-start/deep-start.sh /usr/local/bin/deep-start

# Necessary for the Jupyter Lab terminal
ENV SHELL /bin/bash

# Expand memory usage limit
RUN ulimit -s 32768

# Install user app:
# clone only the last commit from github
RUN git clone --depth 1 -b $branch https://github.com/ai4os-hub/retinopathy-test && \
    cd  retinopathy-test && \
    pip install --no-cache-dir -e . && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    cd ..

# Download default weights and unzip
ENV RETINOPATHY_WEIGHTS_ZIP="1540408813_cpu.zip"
RUN cd /srv/retinopathy-test/models/retinopathy_serve && \
    curl -L "https://share.services.ai4os.eu/index.php/s/XoBRDZkrnigWH4G/download?path=/models&files=${RETINOPATHY_WEIGHTS_ZIP}" \
    -o ${RETINOPATHY_WEIGHTS_ZIP} && \
    unzip ${RETINOPATHY_WEIGHTS_ZIP} && \
    rm ${RETINOPATHY_WEIGHTS_ZIP}

# Open ports (deepaas, monitoring, ide)
EXPOSE 5000 6006 8888

# Launch deepaas
CMD ["deepaas-run", "--listen-ip", "0.0.0.0", "--listen-port", "5000"]

