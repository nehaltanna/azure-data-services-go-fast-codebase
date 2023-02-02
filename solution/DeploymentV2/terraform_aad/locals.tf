locals {
  webapp_name                  = "WebAppName"
  webapp_url                   = "https://${local.webapp_name}.azurewebsites.net"
  functionapp_name             = "FuncAppName"
  functionapp_url              = "https://${local.functionapp_name}.azurewebsites.net"
  aad_webapp_name              = "TestWebAppR"
  aad_functionapp_name         = "TestFuncAppR"

}

