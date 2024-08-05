1. provider.tf 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }
  }
}

provider "azurerm" {
  features {}
}
2. variables.tf
Define variables used across your configuration.


variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "k8s-cluster"
}

variable "location" {
  description = "Location for resources"
  type        = string
  default     = "Italy North"
}

variable "nodecount" {
  description = "Number of virtual machines"
  type        = number
  default     = 2
}

variable "username" {
  description = "Admin username for the virtual machines"
  type        = string
  default     = "adminuser"
}

variable "password" {
  description = "Admin password for the virtual machines"
  type        = string
  default     = "Password1234"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ubuntu_image_version" {
  description = "Ubuntu image version"
  type        = string
  default     = "19.04.201911131"
}
3. network.tf
Define network-related resources.


# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create a subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-tcp-k8s"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-icmp"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-tcp-all"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
4. public_ip.tf
Define public IP resources.

resource "azurerm_public_ip" "vm" {
  count               = var.nodecount
  name                = "${var.prefix}-public-ip-vm${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}
5. network_interface.tf
Define network interfaces.


resource "azurerm_network_interface" "nic" {
  count               = var.nodecount
  name                = "${var.prefix}-nic-vm${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-nic-config-vm${count.index + 1}"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-nic" {
  count                     = var.nodecount
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}
6. virtual_machines.tf
Define the virtual machines and their configurations.

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.nodecount
  name                = "${var.prefix}-vm${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B2s"
  admin_username      = var.username
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  admin_ssh_key {
    username   = var.username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.prefix}-osdisk-${count.index + 1}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "19_04-daily-gen2"
    version   = var.ubuntu_image_version
  }

  connection {
    type        = "ssh"
    user        = var.username
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip_address
    timeout     = "4m"
  }
}
7. output.tf

output "ssh_commands" {
  description = "SSH commands for virtual machines"
  value = [
    for ip in azurerm_public_ip.vm.*.ip_address : "ssh ${var.username}@${ip}"
  ]
}
