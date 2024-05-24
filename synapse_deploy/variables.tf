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
    description = "partner id for tracking"
    type = string
    default = "e3793613-5f71-4f07-87d0-ecee0c0f5522"
  
}

variable "storage_account_name" {
    description = "storage account name"
    type = string
  
}

variable "synapse_name" {
    description = "synapse name"
    type = string
  
}



variable "spark_pool_name" {
    type = string
    description = "Name to be give to the spark pool"
  
}
  
