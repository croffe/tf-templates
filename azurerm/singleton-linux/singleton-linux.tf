# Azure Resource Manager provider
provider "azurerm" main {

}

resource "azurerm_resource_group" "main" {
    name = "${var.name_prefix}-resources"
    location = "eastus"

    tags {
        environment = "Terraform Sandbox"
    }
}

resource "azurerm_virtual_network" "main" {
    name = "${var.name_prefix}-network"
    address_space = ["172.16.0.0/16"]
    location = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"

    tags {
        environment = "Terraform Sandbox"
    }
}

resource "azurerm_subnet" "internal" {
    name = "internal"
    resource_group_name = "${azurerm_resource_group.main.name}"
    address_prefix = "172.16.1.0/24"
    virtual_network_name = "${azurerm_virtual_network.main.name}"
}

# Create public IPs
resource "azurerm_public_ip" "tfpublicip" {
    name                         = "${var.name_prefix}-PublicIP"
    location                     = "${azurerm_resource_group.main.location}"
    resource_group_name          = "${azurerm_resource_group.main.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Sandbox"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "tfdemosg" {
    name                = "${var.name_prefix}-sg"
    location            = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"

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

    tags {
        environment = "Terraform Sandbox"
    }
}

resource "azurerm_network_interface" "main" {
    name = "${var.name_prefix}-nic"
    location = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"
    network_security_group_id = "${azurerm_network_security_group.tfdemosg.id}"

    ip_configuration {
        name = "testconfiguration1"
        subnet_id = "${azurerm_subnet.internal.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.tfpublicip.id}"
    }

    tags {
        environment = "Terraform Sandbox"
    }
}

resource "azurerm_virtual_machine" "main" {
    name = "${var.name_prefix}-vm"
    location = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"
    network_interface_ids = ["${azurerm_network_interface.main.id}"]
    vm_size = "Standard_B1s"

    # Delete all disks on termination
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
    storage_os_disk {
        name              = "${var.name_prefix}_disk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "${var.name_prefix}-hostname"
        admin_username = "${var.user_name}"
    }
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azuser/.ssh/authorized_keys"
            key_data = "${var.pub_key}"
        }
    }
  tags {
    environment = "Terraform Sandbox"
  }
}
