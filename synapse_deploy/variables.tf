variable "resource_group_name" {
  description = "name for resource group"
  type = string
}

variable "location_for_resoruces" {
    description = "location for resources"
    type = string
    default = "eastus"
  
}

variable "partner_id" {
    description = "ID for Azure usage attribution"
    type = string
    default = "3f4ca993-6379-4dec-a7ee-ce3a4f664cc9"
  
}

