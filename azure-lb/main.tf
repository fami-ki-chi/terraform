terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.46.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = "575e51b9-5cc5-4308-a058-95a5ff1bbf73"
  features{}
}

variable "location" {
  description = "Location of the network"
  default     = "japaneast"
}

variable "username" {
  description = "Username for Virtual Machines"
  default     = "USERNAME"
}

variable "password" {
  description = "Password for Virtual Machines"
  default     = "PASSWORD"
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}
