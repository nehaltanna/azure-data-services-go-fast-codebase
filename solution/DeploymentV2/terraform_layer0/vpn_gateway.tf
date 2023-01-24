resource "azurerm_public_ip" "adsgf_vpn_ip" {
  name                = local.vpn_gateway_ip_name
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "adsgf_vpn" {
  name                = local.vpn_gateway_name
  location            = var.resource_location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.adsgf_vpn_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vpn_subnet[0].id
  }

  vpn_client_configuration {
    address_space = [var.vpn_gateway_address_range]   
    
  }
}