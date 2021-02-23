# Azure template for Terraform

## 目次
1. [RG の作成](#anchor1)
2. [VNet とサブネットの作成](#anchor2)
3. [Public IP の作成](#anchor3)
4. [NIC の作成](#anchor4)
5. [NSG の作成と関連付け](#anchor5)
6. [VM の作成](#anchor6)
7. [VPN Gateway の作成](#anchor7)
8. [LB の作成](#anchor8)

<a name="#anchor1"></a>
## RG の作成
```
resource "azurerm_resource_group" "" {
  name     =
  location =
}
```

<a name="#anchor2"></a>
## VNet とサブネットの作成
```
resource "azurerm_virtual_network" "" {
  name                =
  location            =
  resource_group_name =
  address_space       = ["X.X.X.X/X"]
}

resource "azurerm_subnet" "" {
  name                 = ""
  resource_group_name  =
  virtual_network_name =
  address_prefix       = "0.0.0.0/0"
}
```

<a name="#anchor3"></a>
## Public IP の作成
```
resource "azurerm_public_ip" "" {
    name                = ""
    location            =
    resource_group_name =
    allocation_method   = "Dynamic"
}
```

<a name="#anchor4"></a>
## NIC の作成
```
resource "azurerm_network_interface" "" {
  name                 =
  location             =
  resource_group_name  =
  enable_ip_forwarding = false

  ip_configuration {
    name                          = ""
    subnet_id                     =
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          =
  }
}
```

<a name="#anchor5"></a>
## NSG の作成と関連付け
```
resource "azurerm_network_security_group" " " {
    name                = " "
    location            =
    resource_group_name =

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "mgmt-nsg-association" {
  subnet_id                 =
  network_security_group_id =
}
```

<a name="#anchor6"></a>
## VM の作成
```
resource "azurerm_virtual_machine" "" {
  name                  = ""
  location              =
  resource_group_name   =
  network_interface_ids = []
  vm_size               =

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
```

<a name="#anchor7"></a>
## VPN Gateway の作成
```
resource "azurerm_virtual_network_gateway" "" {
  name                = ""
  location            =
  resource_group_name =

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          =
    private_ip_address_allocation = "Dynamic"
    subnet_id                     =
  }
  depends_on = [azurerm_public_ip.vpngw-pip]
}

```

<a name="#anchor8"></a>
## LB の作成
```
resource "azurerm_lb" "" {
  name                = ""
  location            =
  resource_group_name =
  sku                 = "Basic"

  frontend_ip_configuration {
    name                          = ""
    subnet_id                     =
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb" "" {
  name                = ""
  location            =
  resource_group_name =
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = ""
    public_ip_address_id =
  }


resource "azurerm_lb_backend_address_pool" "" {
  loadbalancer_id =
  name            = ""
}

resource "azurerm_lb_probe" "" {
  resource_group_name =
  loadbalancer_id     =
  name                = ""
  port                =
}

resource "azurerm_lb_rule" "" {
  resource_group_name            =
  loadbalancer_id                =
  name                           = ""
  protocol                       = ""
  frontend_port                  =
  backend_port                   =
  frontend_ip_configuration_name = ""
}
```
