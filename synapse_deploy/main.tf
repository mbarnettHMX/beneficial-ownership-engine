terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.104.2"
    }
  }
}

provider "azurerm" {
    partner_id = var.partner_id
    features {
      
    }
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
  numeric  = false
}

resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location_for_resoruces
}


resource "azurerm_storage_account" "storage" {
  name = "bostorage${random_string.random.result}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  account_tier = "Standard"
  account_replication_type = "RAGRS"
  

  network_rules {
    default_action             = "Allow"
    bypass                     = ["AzureServices"]
  }

}

data "azurerm_client_config" "current" {}
resource "azurerm_role_assignment" "storage_account_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}



resource "azurerm_storage_container" "curated" {
  name                  = "curated"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
 
}

resource "azurerm_storage_data_lake_gen2_filesystem" "synapse_filesystem" {
  name               = "bostorage${random_string.random.result}"
  storage_account_id = azurerm_storage_account.storage.id
}

resource "azurerm_synapse_workspace" "synapse" {
  name                           = "bo-synapse${random_string.random.result}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse_filesystem.id
  public_network_access_enabled        = true

  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    
    ignore_changes  = [
      location,
      storage_data_lake_gen2_filesystem_id,
      public_network_access_enabled,
      identity,
      sql_administrator_login  ,
    
    ]
  }

}



resource "azurerm_synapse_firewall_rule" "allow_all" {
  name                 = "allowAll"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}



resource "azurerm_synapse_spark_pool" "synapse_spark_pool" {
  name                                = "bospark${random_string.random.result}"
  synapse_workspace_id                = azurerm_synapse_workspace.synapse.id
  node_size_family                    = "MemoryOptimized"
  node_size                           = "Medium"
  cache_size                          = 50
  compute_isolation_enabled           = false
  dynamic_executor_allocation_enabled = false
  session_level_packages_enabled      = true
  spark_version                       = "3.2"
 
  auto_scale {
    max_node_count = 20
    min_node_count = 3
  }
 

  auto_pause {
    delay_in_minutes = 15
    
  }


  lifecycle {
    ignore_changes = [  
      library_requirement,
    ]
  }
}
resource "azurerm_role_assignment" "synapse_identity_blob_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse.identity[0].principal_id
}

resource "azurerm_synapse_linked_service" "adls_storage" {
  name                 = "LS_Data"
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  type                 = "AzureBlobFS"
  type_properties_json = <<JSON
{
  "url": "https://bostorage${random_string.random.result}.dfs.core.windows.net/"
}
JSON

 
}

resource "null_resource" "set_script_permission" {
  provisioner "local-exec" {
    command = "chmod +x ./upload_notebooks.sh"
  }
}

resource "null_resource" "upload_notebooks" {
  provisioner "local-exec" {
    command = "./upload_notebooks.sh bo-synapse${random_string.random.result} ${var.resource_group_name} ./synapse_notebooks"
  }
}


