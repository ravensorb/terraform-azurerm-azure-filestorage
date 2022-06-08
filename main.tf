#---------------------------------
# Local declarations
#---------------------------------
locals { 
  name                = var.name == "" ? "-filestorage" : "-${var.name}"
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  resource_prefix     = var.resource_prefix == "" ? local.resource_group_name : var.resource_prefix
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)

  shares = { for idx, share in var.shares : share.name => {
    idx : idx,
    share : share,
    }
  }

  timeout_create  = "45m"
  timeout_update  = "15m"
  timeout_delete  = "15m"
  timeout_read    = "15m"
}

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "true"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "ResourceName" = "${var.resource_group_name}" }, var.tags, )
}

#-------------------------------------
# Networking
#-------------------------------------

data "azurerm_virtual_network" "vnet" {
  count                 = var.storage_account_limit_access_to_subnets ? 1 : 0
  name                  = var.virtual_network_name
  resource_group_name   = var.virtual_network_resource_group_name == null ? var.resource_group_name : var.virtual_network_resource_group_name
}

## External Data References
data "azurerm_subnet" "snet" {
  count                 = var.storage_account_limit_access_to_subnets ? 1 : 0
  name                  = var.subnet_name
  resource_group_name   = element(data.azurerm_virtual_network.vnet.*.resource_group_name, 0)
  virtual_network_name  = element(data.azurerm_virtual_network.vnet.*.name, 0)
}

#-------------------------------------
## Storage Accounts
#-------------------------------------
data "azurerm_storage_account" "storage" {
  count               = var.create_storage_account == false && var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name != null ? var.storage_account_resource_group_name : local.resource_group_name
}

resource "azurerm_storage_account" "storage" {
  count                     = var.create_storage_account || var.storage_account_name == null ? 1 : 0

  name                      = var.storage_account_name != null ? var.storage_account_name : format("%sst%s", lower(replace(local.resource_prefix, "/[[:^alnum:]]/", "")), lower(replace(local.name, "/[[:^alnum:]]/", "")))
  resource_group_name       = local.resource_group_name
  location                  = local.location
  account_kind              = var.storage_account_kind
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_replication_type
  #access_tier              = var.storage_acccount_access_tier 
  
  large_file_share_enabled  = var.storange_account_large_file_share_enabled

  tags                      = merge({ "ResourceName" = format("%sst%s", lower(replace(local.resource_prefix, "/[[:^alnum:]]/", "")), lower(replace(local.name, "/[[:^alnum:]]/", ""))) }, var.tags, )

  dynamic "azure_files_authentication" {
    for_each = var.storage_account_authentication_type != "" ? [1] : [0]
    content {
      directory_type = var.storage_account_authentication_type
      # dynamic "active_directory" {
      #   for_each = var.storage_account_authentication_type == "AADS" : [1] : []

      #   content {
      #     domain_name = var.storage_account_authentication_domain_name
      #   }
      # }

      dynamic "active_directory" {
        for_each = var.storage_account_authentication_type == "AD" ? [1] : []

        content {
          domain_name         = var.storage_account_authentication_domain_name
          storage_sid         = var.storage_account_authentication_storage_sid
          domain_sid          = var.storage_account_authentication_domain_sid
          domain_guid         = var.storage_account_authentication_domain_guid
          forest_name         = var.storage_account_authentication_forest_name
          netbios_domain_name = var.storage_account_authentication_netbios_domain_name
        }
      }
    }
  }

  timeouts {
    create  = local.timeout_create
    delete  = local.timeout_delete
    read    = local.timeout_read
    update  = local.timeout_update
  }
}

# Storage Account Network rules
resource "azurerm_storage_account_network_rules" "storage-netrules" {  
  count                       = var.storage_account_limit_access_to_subnets ? 1 : 0
  storage_account_id          = element(concat(azurerm_storage_account.storage.*.id, data.azurerm_storage_account.storage.*.id, [""]), 0)
  virtual_network_subnet_ids  = [ data.azurerm_subnet.snet.0.id ]
  default_action              = "Deny"
  
  bypass = [
    "Metrics",
    "Logging",
    "AzureServices"
  ]
}

## Storage Shares
resource "azurerm_storage_share" "storage" {
  for_each              = local.shares
  name                 = "${local.resource_prefix}-ss-${each.value.share.name}"
  storage_account_name  = element(concat(azurerm_storage_account.storage.*.name, data.azurerm_storage_account.storage.*.name), 0)
  quota                 = try(each.value.share.quota, 5120)
  # access_tier           = try(each.value.share.access_tier, "Hot")
  
  depends_on = [
    azurerm_storage_account.storage,
    data.azurerm_storage_account.storage
  ]

  acl {
    id = "GhostedRecall"
    access_policy {
      permissions = "r"
    }
  }

  timeouts {
    create  = local.timeout_create
    delete  = local.timeout_delete
    read    = local.timeout_read
    update  = local.timeout_update
  }
}
