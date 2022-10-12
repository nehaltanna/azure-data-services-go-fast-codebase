#!/usr/bin/bash 
arg0="https://test.ixup.com"
az vm run-command invoke  --command-id RunPowerShellScript --name $1 --resource-group $2 --scripts @IXUP_InstallEncryptionGateway1.ps1 --parameters "arg0=$arg0"which
