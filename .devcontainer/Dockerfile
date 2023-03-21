# You can pick any Debian/Ubuntu-based image. 😊
FROM mcr.microsoft.com/vscode/devcontainers/base:0-jammy

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    # Install the Azure CLI
    && bash /tmp/library-scripts/azcli-debian.sh \
    # Clean up
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts \
    && apt-get update  \
    && sudo apt-get install -y wget apt-transport-https software-properties-common  \
    && wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb  \
    && sudo dpkg -i packages-microsoft-prod.deb  \
    && sudo apt-get update  \
    && sudo apt-get install -y powershell=7.3.0-1.deb -V --allow-downgrades  \
    && rm ./packages-microsoft-prod.deb  \
    && sudo apt install -y aspnetcore-runtime-6.0=6.0.8-1 dotnet-apphost-pack-6.0=6.0.8-1 dotnet-host=6.0.8-1 dotnet-hostfxr-6.0=6.0.8-1 dotnet-runtime-6.0=6.0.8-1 dotnet-sdk-6.0=6.0.400-1 dotnet-targeting-pack-6.0=6.0.8-1 --allow-downgrades \
    && wget https://github.com/google/go-jsonnet/releases/download/v0.17.0/jsonnet-go_0.17.0_linux_amd64.deb  \
    && sudo dpkg -i jsonnet-go_0.17.0_linux_amd64.deb \
    && sudo rm jsonnet-go_0.17.0_linux_amd64.deb \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
    && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && sudo apt-get update && sudo apt-get install terraform \
    && wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.35.14/terragrunt_linux_amd64 \
    && mv terragrunt_linux_amd64 terragrunt \
    && sudo chmod +x terragrunt \
    && sudo mv terragrunt /usr/local/bin/terragrunt \
    && sudo apt-get install -y figlet \
    && sudo apt-get install -y lolcat \
    && sudo gem install lolcat \
    && sudo apt-get install -y boxes 
    # DBT
    # https://learn.microsoft.com/nl-be/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16#ubuntu18
    #&& sudo apt install python3.10-venv \
    #&& sudo apt-get install -y pip \
    #&& pip install dbt-core   \
    #&& pip install dbt-sqlserver 
# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

