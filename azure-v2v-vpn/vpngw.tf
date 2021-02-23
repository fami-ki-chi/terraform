locals {
  location               = "japaneast"
  resource-group         = "tf-lb-rg"
  prefix                 = "test"
  vnet-address-space1    = "100.0.0.0/16"
  vnet-default-subnet1   = "100.0.0.0/24"
  vnet-gateway-subnet1   = "100.0.1.0/24"
  vnet-address-space2    = "200.0.0.0/16"
  vnet-default-subnet2   = "200.0.0.0/24"
  vnet-gateway-subnet2   = "200.0.1.0/24"
  shared-key             = "yamaha"
}

resource "azurerm_resource_group" "tf-rg" {
  name     = local.resource-group
  location = var.location
}

# Vnet resource 1

resource "azurerm_virtual_network" "tf-vnet1" {
  name                = "${local.prefix}-vnet1"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = ["${local.vnet-address-space1}"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet1.name
  address_prefixes     = ["${local.vnet-default-subnet1}"]
}

resource "azurerm_subnet" "GatewaySubnet1" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet1.name
  address_prefixes     = ["${local.vnet-gateway-subnet1}"]
}

# Vnet resource 2

resource "azurerm_virtual_network" "tf-vnet2" {
  name                = "${local.prefix}-vnet2"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = ["${local.vnet-address-space2}"]
}

resource "azurerm_subnet" "default2" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet2.name
  address_prefixes     = ["${local.vnet-default-subnet2}"]
}

resource "azurerm_subnet" "GatewaySubnet2" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet2.name
  address_prefixes     = ["${local.vnet-gateway-subnet2}"]
}

# VM resouce

resource "azurerm_network_interface" "vm-1-nic" {
  name                 = "${local.prefix}-vm-1-nic"
  location             = azurerm_resource_group.tf-rg.location
  resource_group_name  = azurerm_resource_group.tf-rg.name
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "tf-vm-1" {
  name                  = "${local.prefix}-vm-1"
  location              = azurerm_resource_group.tf-rg.location
  resource_group_name   = azurerm_resource_group.tf-rg.name
  network_interface_ids = [azurerm_network_interface.vm-1-nic.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# VPN Gateway resouce 1

resource "azurerm_public_ip" "vpngw-pip1" {
  name                = "${local.prefix}-vpngw-pip1"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "tf-vpngw1" {
  name                = "tf-vpn-gw1"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpngw-pip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnet1.id
  }
  depends_on = [azurerm_public_ip.vpngw-pip1]
}

# VPN Gateway resouce 2

resource "azurerm_public_ip" "vpngw-pip2" {
  name                = "${local.prefix}-vpngw-pip2"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "tf-vpngw2" {
  name                = "tf-vpn-gw2"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpngw-pip2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnet2.id
  }
  depends_on = [azurerm_public_ip.vpngw-pip2]
}

# connection resource

resource "azurerm_virtual_network_gateway_connection" "tf-connection1" {
  name                = "tf-connection1"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.tf-vpngw1.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.tf-vpngw2.id

  shared_key = "${local.shared-key}"
}

resource "azurerm_virtual_network_gateway_connection" "tf-connection2" {
  name                = "tf-connection2"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.tf-vpngw2.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.tf-vpngw1.id

  shared_key = "${local.shared-key}"
}
