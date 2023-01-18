#!/bin/bash
# VALIDATED ON Linux (ubuntu 22.04) #

sudo apt-get update  && \
sudo apt-get install -y wget apt-transport-https software-properties-common && \
wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/powershell_7.3.0-1.deb_amd64.deb && \
sudo dpkg -i powershell_7.3.0-1.deb_amd64.deb  && \
rm ./powershell_7.3.0-1.deb_amd64.deb  && \

wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb  && \
sudo dpkg -i packages-microsoft-prod.deb && \
sudo apt-get update && \
sudo apt install -y aspnetcore-runtime-6.0=6.0.8-1 dotnet-apphost-pack-6.0=6.0.8-1 dotnet-host=6.0.8-1 dotnet-hostfxr-6.0=6.0.8-1 dotnet-runtime-6.0=6.0.8-1 dotnet-sdk-6.0=6.0.400-1 dotnet-targeting-pack-6.0=6.0.8-1 --allow-downgrades && \
rm packages-microsoft-prod.deb && \

wget https://github.com/google/go-jsonnet/releases/download/v0.17.0/jsonnet-go_0.17.0_linux_amd64.deb  && \
sudo dpkg -i jsonnet-go_0.17.0_linux_amd64.deb && \
sudo rm jsonnet-go_0.17.0_linux_amd64.deb && \
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
sudo apt-get update && sudo apt-get install terraform && \
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.35.14/terragrunt_linux_amd64 && \
sudo mv terragrunt_linux_amd64 terragrunt && \
sudo chmod u+x terragrunt && \
sudo mv terragrunt /usr/local/bin/terragrunt && \
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \

#Boxes, Figlet and LolCat
sudo apt-get install figlet lolcat boxes -y 