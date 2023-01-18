#!/bin/bash
# VALIDATED ON Linux (ubuntu 22.04) #


#Github Runner Software
mkdir actions-runner && cd actions-runner# Download the latest runner package && \
curl -o actions-runner-linux-x64-2.296.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.296.0/actions-runner-linux-x64-2.296.0.tar.gz && \
tar xzf ./actions-runner-linux-x64-2.296.0.tar.gz 
read -p "Please enter github runner token: " GHTOKEN 
read -p "Please enter github repo url eg. https://github.com/microsoft/azure-data-services-go-fast-codebase  " GHURL 
./config.sh --url $GHURL --token $GHTOKEN
rm actions-runner-linux-x64-2.296.0.tar.gz 
sudo ./svc.sh install 
sudo ./svc.sh start

