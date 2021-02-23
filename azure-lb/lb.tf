locals {
  location       = "japaneast"
  resource-group = "tf-lb-rg"
  prefix         = "test"
  vnet-address-space = "100.0.0.0/16"
  vnet-default-subnet = 100.0.0.0/24"
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

# VM resouce 1

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

VM resouce 2

resource "azurerm_network_interface" "vm-2-nic" {
  name                 = "${local.prefix}-vm-2-nic"
  location             = azurerm_resource_group.tf-rg.location
  resource_group_name  = azurerm_resource_group.tf-rg.name
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "tf-vm-2" {
  name                  = "${local.prefix}-vm-2"
  location              = azurerm_resource_group.tf-rg.location
  resource_group_name   = azurerm_resource_group.tf-rg.name
  network_interface_ids = [azurerm_network_interface.vm-2-nic.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk2"
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

# Internal LB

/*
resource "azurerm_lb" "tf-int-lb" {
  name                = "tf-int-lb"
  location            = local.location
  resource_group_name = local.resource-group
  sku                 = "Basic"

  frontend_ip_configuration {
    name                          = "tf-int-lb-frontend"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "int-pool" {
  loadbalancer_id = azurerm_lb.tf-int-lb.id
  name            = "int-pool"
}

resource "azurerm_lb_probe" "tf-int-lb" {
  resource_group_name = local.resource-group
  loadbalancer_id     = azurerm_lb.tf-int-lb.id
  name                = "ssh"
  port                = 22
}

resource "azurerm_lb_rule" "tf-int-lb" {
  resource_group_name            = local.resource-group
  loadbalancer_id                = azurerm_lb.tf-int-lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "tf-int-lb-frontend"
}
*/

# External LB

/*
resource "azurerm_public_ip" "lb-pip" {
  name                = "${local.prefix}-lb-pip"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_lb" "tf-ext-lb" {
  name                = "tf-ext-lb"
  location            = local.location
  resource_group_name = local.resource-group
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "tf-ext-lb-frontend"
    public_ip_address_id = azurerm_public_ip.lb-pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "ext-pool" {
  loadbalancer_id = azurerm_lb.tf-ext-lb.id
  name            = "ext-pool"
}

resource "azurerm_lb_probe" "tf-ext-lb" {
  resource_group_name = local.resource-group
  loadbalancer_id     = azurerm_lb.tf-ext-lb.id
  name                = "http"
  port                = 80
}

resource "azurerm_lb_rule" "tf-ext-lb" {
  resource_group_name            = local.resource-group
  loadbalancer_id                = azurerm_lb.tf-ext-lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "tf-ext-lb-frontend"
}
*/
