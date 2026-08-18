terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.80.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_network_manager" "res-0" {
  description         = "Created for sample_vnet"
  location            = "eastus"
  name                = "sample_vnet-network-manager"
  resource_group_name = "Testing_Ground"
  scope_accesses      = []
  tags                = {}
  scope {
    management_group_ids = []
    subscription_ids     = ["/subscriptions/84d5e3cd-c761-4bd4-9b6f-96d03251739b"]
  }
}
resource "azurerm_network_manager_ipam_pool" "res-1" {
  address_prefixes   = ["21.0.0.0/28"]
  description        = "Created from virtual network create experience"
  display_name       = "sample_vnet-ipv4-pool"
  location           = "eastus"
  name               = "sample_vnet-ipv4-pool"
  network_manager_id = azurerm_network_manager.res-0.id
  parent_pool_name   = ""
  tags               = {}
}
resource "azurerm_network_security_group" "res-2" {
  location            = "eastus"
  name                = "sample-private-nsg"
  resource_group_name = "Testing_Ground"
  security_rule       = []
  tags                = {}
}
resource "azurerm_network_security_group" "res-3" {
  location            = "eastus"
  name                = "sample-public-nsg"
  resource_group_name = "Testing_Ground"
  security_rule       = []
  tags                = {}
}
resource "azurerm_virtual_network" "res-4" {
  address_space                  = ["21.0.0.0/28"]
  bgp_community                  = ""
  dns_servers                    = []
  edge_zone                      = ""
  flow_timeout_in_minutes        = 0
  location                       = "eastus"
  name                           = "sample_vnet"
  private_endpoint_vnet_policies = "Disabled"
  resource_group_name            = "Testing_Ground"
  subnet = [{
    address_prefixes                              = ["21.0.0.0/29"]
    default_outbound_access_enabled               = false
    delegation                                    = []
    id                                            = "/subscriptions/84d5e3cd-c761-4bd4-9b6f-96d03251739b/resourceGroups/Testing_Ground/providers/Microsoft.Network/virtualNetworks/sample_vnet/subnets/private-subnet"
    name                                          = "private-subnet"
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
    route_table_id                                = ""
    security_group                                = azurerm_network_security_group.res-2.id
    service_endpoint_policy_ids                   = []
    service_endpoints                             = []
    }, {
    address_prefixes                              = ["21.0.0.8/29"]
    default_outbound_access_enabled               = false
    delegation                                    = []
    id                                            = "/subscriptions/84d5e3cd-c761-4bd4-9b6f-96d03251739b/resourceGroups/Testing_Ground/providers/Microsoft.Network/virtualNetworks/sample_vnet/subnets/public-subnet"
    name                                          = "public-subnet"
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
    route_table_id                                = ""
    security_group                                = azurerm_network_security_group.res-3.id
    service_endpoint_policy_ids                   = []
    service_endpoints                             = []
  }]
  tags = {}
  ip_address_pool {
    id                     = azurerm_network_manager_ipam_pool.res-1.id
    number_of_ip_addresses = "16"
  }
}
