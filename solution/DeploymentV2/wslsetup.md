# Setting up a development environment
In order to provide a consistent and reliable deployment environment we ulilize a **linux** based deployment environment. **Ubuntu 22.04.01 LTS** is our current standard. You can obtain the required linux development environment in a number of different ways. Please refer to the list below and select the option that will work best for you.

1. Windows: On windows you can set up the linux environment using WSL2. 
   - [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)
   - [Windows Store Ubuntu 22.04.01 LTS](https://apps.microsoft.com/store/detail/ubuntu-22041-lts/9PN20MSR04DW)
1. Cloud Hosted Linux Virtual Machine: 
    - Virtual Machine: You can setup a your deployment environment on a cloud hosted linux virtual machine. Eg. [Ubuntu VM in Azure](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/canonical.0001-com-ubuntu-server-jammy?tab=Overview&exp=ubp8) 
1. OSX:
    - Docker or Linux virtual machine - **note that we do not provide detailed instructions for this and have not tested deployments using OSX

Once you have obtained your linux environment you will need to install the required build and deployment tools. 