
/*Below we are using "Azure" as provider for terraform (TF) and provided the required details in order to provision a VM in azure. Clinet ID and secret vaues related to the app (packer) created within Azure, this will allow to authunticate the Azure by using service principle account  */

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"  
}

resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "${var.vnet}"
  resource_group_name = "${var.vnet_resource_group_name}"
  address_space       = ["${lookup(var.address_space, var.vnet)}"]
#  address_space       = "${var.vnet_address_space}"
  location            = "${var.location}"
 }

resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet}"
  resource_group_name  = "${azurerm_virtual_network.virtualnetwork.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.virtualnetwork.name}"
  address_prefix       = "${lookup(var.address_prefix, var.subnet)}"
}
 
resource "azurerm_network_interface" "packernic" {
  name                = "ipconfig1"
  location            = "${var.location}"
  resource_group_name = "${azurerm_virtual_network.virtualnetwork.resource_group_name}"

    ip_configuration {
      name                          = "ipconfig"
      subnet_id                     = "${azurerm_subnet.subnet.id}"
      private_ip_address_allocation = "Static"
      private_ip_address            = "${var.privateipaddress}"
    }

}


resource "azurerm_virtual_machine" "transfer" {
  name                  = "${var.VM_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.VM_resource_group_name}"
  vm_size               = "${var.VM_size}"
  network_interface_ids = ["${azurerm_network_interface.packernic.id}"]

  storage_os_disk {
    name          = "terraform-osdisk"
    image_uri     = "https://packerimage.blob.core.windows.net/system/Microsoft.Compute/Images/images/packer-osDisk.168316ed-67b7-4f1d-9c8e-7bdaca9b71ed.vhd"     vhd_uri       = "https://packerimage.blob.core.windows.net/vmcontainerd661a763-2708-4aa8-b289-7de0f0bc8952/osDisk.d661a763-2708-4aa8-b289-7de0f0bc8952.vhd"   
    os_type       = "windows"
    create_option = "FromImage"
                  }

  os_profile {
    computer_name  = "${var.VM_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
             }
}


/*
Here we are using Azure extensions "JsonADDomainExtension" and "CustomScriptExtension" in order to join the provisioned VM to the "hautelook.local" domain and to run powershell commands which moves the required puppet.conf file and sends the cert sign request to the puppet master. */


/*
The join domain extension has the join option set to 3 by default, which means it will create the AD object for the machine. It will also reboot the VM automatically.*/


resource "azurerm_virtual_machine_extension" "joindomain" {
  name                 = "join-domain"
  location             = "${azurerm_virtual_machine.transfer.location}"
  resource_group_name  = "${azurerm_virtual_machine.transfer.resource_group_name}"
  virtual_machine_name = "${azurerm_virtual_machine.transfer.name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.0"

  settings = <<SETTINGS
    {
        "Name": "hautelook.local",
        "OUPath": "OU=Servers,OU=hautelook,DC=hautelook,DC=local",
        "User": "${var.domain_user_name}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "Password": "${var.domain_user_password}"
    }
PROTECTED_SETTINGS
}



resource "azurerm_virtual_machine_extension" "puppet" {
  name                 = "puppet"
  location             = "${azurerm_virtual_machine.transfer.location}"
  resource_group_name  = "${azurerm_virtual_machine.transfer.resource_group_name}"
  virtual_machine_name = "${azurerm_virtual_machine.transfer.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"
  depends_on           = ["azurerm_virtual_machine_extension.joindomain"]

  settings = <<SETTINGS
    {
    "commandToExecute": "powershell.exe refreshenv;copy-item C:\\ProgramData\\puppet.conf C:\\ProgramData\\PuppetLabs\\puppet\\etc\\;remove-item C:\\ProgramData\\PuppetLabs\\puppet\\etc\\ssl\\* -Recurse -Force; \"&\" 'C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet.bat' agent -t"

}SETTINGS
}

