resource "azurerm_public_ip" "adsgf_vpn_ip" {
  count               = var.deploy_vpn ? 1 : 0
  name                = local.vpn_gateway_ip_name
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "adsgf_vpn" {
  count               = var.deploy_vpn ? 1 : 0
  name                = local.vpn_gateway_name
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"
  generation =  "Generation1"


  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.adsgf_vpn_ip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vpn_subnet[0].id
  }

  vpn_client_configuration {
    address_space = [var.vpn_gateway_address_range]
    aad_tenant = local.vpn_tenant
    aad_audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    aad_issuer = local.vpn_issuer
    vpn_client_protocols = [ "OpenVPN" ]
    vpn_auth_types = ["AAD"]
  }
}