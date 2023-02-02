resource "random_uuid" "function_app_reg_role_id" {}

# This is used for auth in the Azure Function
resource "azuread_application" "function_app_reg" {
  owners          = ["a701a08a-8732-4dc2-b551-617484bd3ada"]
  identifier_uris = ["api://${local.functionapp_name}"]
  display_name    = local.aad_functionapp_name
  web {
    homepage_url = local.functionapp_url
    implicit_grant {
      access_token_issuance_enabled = false
    }
  }
  app_role {
    allowed_member_types = ["Application", "User"]
    id                   = random_uuid.function_app_reg_role_id.result
    description          = "Used to applications to call the ADS Go Fast functions"
    display_name         = "FunctionAPICaller"
    enabled              = true
    value                = "FunctionAPICaller"
  }
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "b340eb25-3456-403f-be2f-af7a0d370277"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "function_app" {
  owners         = ["a701a08a-8732-4dc2-b551-617484bd3ada"]
  application_id = azuread_application.function_app_reg.application_id
}



