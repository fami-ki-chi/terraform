locals {
  location              = "japaneast"
  resource-group        = "tf-lb-rg"
  prefix                = "test"
  vnet-address-space    = "100.0.0.0/16"
  vnet-default-subnet   = "100.0.0.0/24"
  vnet-gateway-subnet   = "100.0.1.0/24"
  onpre-gateway-address = "1.2.3.4"
  onpre-address-space   = "192.168.100.0/24"
  shared-key            = "yamaha" 
}

resource "azurerm_resource_group" "tf-rg" {
  name     = local.resource-group
  location = var.location
}

# Vnet resource

resource "azurerm_virtual_network" "tf-vnet" {
  name                = "${local.prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = ["${local.vnet-address-space}"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = ["${local.vnet-default-subnet}"]
}

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  address_prefixes     = ["${local.vnet-gateway-subnet}"]
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

# VPN Gateway resouce

resource "azurerm_public_ip" "vpngw-pip" {
  name                = "${local.prefix}-vpngw-pip"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "tf-vpngw" {
  name                = "tf-vpn-gw"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpngw-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway-subnet.id
  }
  depends_on = [azurerm_public_ip.vpngw-pip]
}

resource "azurerm_local_network_gateway" "tf-lngw" {
  name                = "tf-lngw"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  gateway_address     = "${local.onpre-gateway-address}"
  address_space       = ["${local.onpre-address-space}"]
}

resource "azurerm_virtual_network_gateway_connection" "tf-connection" {
  name                = "tf-connection"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.tf-vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.tf-lngw.id

  shared_key = "${local.shared-key}"
}
