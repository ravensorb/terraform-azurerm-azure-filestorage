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

	# Name of the azure file sync instance (default "filesync")
	name = "filesync"

  # By default, this module will create a resource group, proivde the name here
  # to use an existing resource group, specify the existing resource group name, 
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG. 

	# Whether to create resource group and use it for all networking resources (default "true")
	create_resource_group = true
	# A container that holds related resources for an Azure solution (default "rg-filesync")
	resource_group_name = "rg-filesync"

	# The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' (default "eastus2")
	location = "eastus2"

	# (Optional) Prefix to use for all resoruces created (Defaults to resource_group_name)
	resource_prefix = "shared-fstg"

	# (Optional) Indicates the name of vnet to limit access to (Reqired if limited access) (default "")
	virtual_network_name = ""

	# (Optional) Indicates the name of resource group that contains the vnet to limit access to (Reqired if limited access) (default "")
	virtual_network_resource_group_name = ""

	# (Optional) Indicates the name of subnet to limit access to (Reqired if limited access) (default "")
	subnet_name = ""

	# (Optional) Storage account to add shares to (default null)
	storage_account_name = null

	# (Optional) Resource Group that contains the Storage account to add shares to (default null)
	storage_account_resource_group_name = null

	# (Optional) Indicates the storage tier to allocate (default "Standard")
	storage_account_tier = "Standard"

	# (Optional) Indicates the replication type to use for the storage account (default "LRS")
	storage_account_replication_type = "LRS"

	# (Optional) Indicates if access should be limited to specific subnets (default "false")
  # Note: requires settings virtual_network_name, virtual_network_resource_group_name, and subnet_net
	storage_account_limit_access_to_subnets = false

	# (Optional) Indicates the type of authentication to enable (blank, AD, AADDS) (default "")
	storage_account_authentication_type = ""

	# (Required for AD) Specifies the security identifier (SID) for Azure Storage. (default null)
	storage_account_authentication_storage_sid = null

	# (Required for AD) Specifies the security identifier (SID). (default null)
	storage_account_authentication_domain_sid = null

	# (Required for AD) Specifies the domain GUID. (default null)
	storage_account_authentication_domain_guid = null

	# (Required for AD) Specifies the Active Directory forest. (default null)
	storage_account_authentication_forest_name = null

	# (Required for AD) Specifies the NetBIOS domain name. (default null)
	storage_account_authentication_netbios_domain_name = null

	# (Optional) Indicates the name of the domain to use for authentication (default "")
	storage_account_authentication_domain_name = ""

	# Storage Share details
	shares = [
		{ name = "storage", quota = 1024 },
		{ name = "archive", access_tier = "Premium", quota = 10240 }
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
