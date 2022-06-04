# Azure File Sync Terraform module

Terraform module to create complete Azure File Storage service.

## Module Usage

```hcl
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "azure-filestorage" {
  source  = "ravensorb/azure-filestorage/azurerm"

  # The name to use for this instance
  name                = "filestorage"

  # A prefix to use for all resouyrces created (if left blank, the resource group name will be used)
  resource_prefix     = "shared-eastus2"

  # By default, this module will create a resource group, proivde the name here
  # to use an existing resource group, specify the existing resource group name, 
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG. 
  resource_group_name = "shared-eastus2-rg-filestorage"
  
  # Location to deploy into
  location            = "eastus2"

  # Set to true to limit access to specific subnets.  
  # Note: requires settings virtual_network_name, virtual_network_resource_group_name, and subnet_net
  storage_account_limit_access_to_subnets = false
  # VNet and Subnet details
  # The vnet to use to deploy this into
  #virtual_network_name                = ""
  # The resource group name for vnet to use to deploy this into
  #virtual_network_resource_group_name = "" # Set to null to use the sameresource group 
  # The number of the subnet to use only needed if limited access to specific subnets
  #subnet_name                         = ""

  # Storage Account Settings
  storage_account_tier                                = "Standard"
  storage_account_replication_type                    = "LRS"

  # Storage Account Authentication
  #storage_account_authentication_type                 = null
  #storage_account_authentication_domain_name          = null
  #storage_account_authentication_storage_sid          = null
  #storage_account_authentication_domain_sid           = null
  #storage_account_authentication_domain_guid          = null
  #storage_account_authentication_forest_name          = null
  #storage_account_authentication_netbios_domain_name  = null

  # Storage Account Settings
  shares = [
    {
      share_name  = "storage"
      share_quota = 1024
      
    },
    {
      share_name  = "archive"
    },
  ]

  # Adding TAG's to your Azure resources (Required)
  tags = {
    CreatedBy   = "Shawn Anderson"
    CreatedOn   = "2022/05/20"
    CostCenter  = "IT"
    Environment = "PROD"
    Critical    = "YES"
    Location    = "eastus2"
    Solution    = "filestorage"
    ServiceClass = "Gold"
  }
}

```

## Terraform Usage

To run this example you need to execute following Terraform commands

```hcl
terraform init
terraform plan
terraform apply

```

Run `terraform destroy` when you don't need these resources.

## Outputs

Name | Description
---- | -----------
`resource_group_name`|The name of the resource group in which resources are created
`resource_group_id`|The id of the resource group in which resources are created
`resource_group_location`|The location of the resource group in which resources are created
`virtual_network_name`|The name of the virtual network
`virtual_network_id`|The id of the virtual network
`storage_account_id`|The id of the storage account that was used/created
`storage_account_name`|The name of the storage account that was used/created
