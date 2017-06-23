variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "vnet" {
   type = "string"
   description = "Enter the name of the VNET if not exist it will create new resource"
}

variable "address_space" {
   type = "map"
   description = "Select the vnet to insert the address_space"
   default = {
    "NRHL-WestUS-1"= "10.242.0.0/22"
}

}

/*
variable "vnet_address_space" {
    type = "list" 
     }
*/


variable "subnet" {
      type = "string"
      description = "Please enter the name of subnet (QA, Development, Staging), Changing this forces a new resource to be created"
}

variable "address_prefix" {
         type = "map"
         description = "Select the subnet to insert the addres_prefix"
         default = {
         "QA" = "10.242.1.0/24"
         "Development" = "10.242.0.128/25"
         "Staging" = "10.242.2.0/25"
}

}
     
variable "location" {
      type = "string"
      description = "Please enter the location, Changing this forces a new resource to be created"
      default = "West US"
}


variable "privateipaddress" {
   type = "string"
   description = "Static IP Address"
}


variable "VM_name" {
      type = "string"
      description = "Please enter the name of VM"
}


variable "VM_size" {
      type = "string"
      description = "Please enter the size of VM"
      default = "Standard_DS1_v2"
}

variable "admin_username" {
    type = "string"
    description = "Please enter the admin user name for VM ex:nrhladmin"

}

variable "admin_password" {
    type = "string"
    description = "Please enter the admin password for VM"

}

variable "vnet_resource_group_name" {
    type = "string"
    description = " Please enter the name of resource group (EnterpriseApps-Platform-PoC, EnterpriseApps-Network, EnterpriseApps-Platform, EnterpriseApps-GP-QA, EnterpriseApps-GP-Prod, EnterpriseApps-GP-NonProd),Changing this forces a new resource to be created"
}

variable "VM_resource_group_name" {
    type = "string"
    description = " Please enter the name of resource group (EnterpriseApps-Platform-PoC, EnterpriseApps-Network, EnterpriseApps-Platform, EnterpriseApps-GP-QA, EnterpriseApps-GP-Prod, EnterpriseApps-GP-NonProd),Changing this forces a new resource to be created"
}





variable "domain_user_name" {
    type = "string"    
    description = "Enter the name of the domain user to join the VM into domain ex:hautelook\\Gangadhar.Reddy"
}

variable "domain_user_password" {
    type = "string"
    description = "Enter the name of the domain user password to join the VM into domain"
}

