param virtualNetworks_sample_vnet_name string = 'sample_vnet'
param networkSecurityGroups_sample_public_nsg_name string = 'sample-public-nsg'
param networkSecurityGroups_sample_private_nsg_name string = 'sample-private-nsg'
param networkManagers_sample_vnet_network_manager_name string = 'sample_vnet-network-manager'
param addressPrefixes_sample_vnet_address_prefixes array = [
  '21.0.0.0/28'
]
param addressPrefixes_private_subnet_address_prefixes array = [
  '21.0.0.0/29'
]
param addressPrefixes_public_subnet_address_prefixes array = [
  '21.0.0.8/29'
]

resource networkManagers_sample_vnet_network_manager_name_resource 'Microsoft.Network/networkManagers@2025-07-01' = {
  name: networkManagers_sample_vnet_network_manager_name
  location: 'eastus'
  properties: {
    description: 'Created for sample_vnet'
    networkManagerScopes: {
      managementGroups: []
      subscriptions: [
        '/subscriptions/84d5e3cd-c761-4bd4-9b6f-96d03251739b'
      ]
    }
    networkManagerScopeAccesses: []
  }
}

resource networkSecurityGroups_sample_private_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  name: networkSecurityGroups_sample_private_nsg_name
  location: 'eastus'
  properties: {
    securityRules: []
  }
}

resource networkSecurityGroups_sample_public_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  name: networkSecurityGroups_sample_public_nsg_name
  location: 'eastus'
  properties: {
    securityRules: []
  }
}

resource networkManagers_sample_vnet_network_manager_name_sample_vnet_ipv4_pool 'Microsoft.Network/networkManagers/ipamPools@2025-07-01' = {
  parent: networkManagers_sample_vnet_network_manager_name_resource
  name: 'sample_vnet-ipv4-pool'
  location: 'eastus'
  properties: {
    description: 'Created from virtual network create experience'
    displayName: 'sample_vnet-ipv4-pool'
    addressPrefixes: addressPrefixes_sample_vnet_address_prefixes
  }
}

resource virtualNetworks_sample_vnet_name_resource 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: virtualNetworks_sample_vnet_name
  location: 'eastus'
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes_sample_vnet_address_prefixes
      ipamPoolPrefixAllocations: [
        {
          numberOfIpAddresses: '16'
          pool: {
            id: resourceId(
              'Microsoft.Network/networkManagers/ipamPools',
              networkManagers_sample_vnet_network_manager_name,
              '${virtualNetworks_sample_vnet_name}-ipv4-pool'
            )
          }
        }
      ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    privateEndpointVNetPolicies: 'Disabled'
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
  dependsOn: [
    networkManagers_sample_vnet_network_manager_name_sample_vnet_ipv4_pool
  ]
}

resource virtualNetworks_sample_vnet_name_private_subnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: '${virtualNetworks_sample_vnet_name}/private-subnet'
  properties: {
    addressPrefixes: addressPrefixes_private_subnet_address_prefixes
    ipamPoolPrefixAllocations: [
      {
        numberOfIpAddresses: '8'
        pool: {
          id: networkManagers_sample_vnet_network_manager_name_sample_vnet_ipv4_pool.id
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroups_sample_private_nsg_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
  dependsOn: [
    virtualNetworks_sample_vnet_name_resource
  ]
}

resource virtualNetworks_sample_vnet_name_public_subnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: '${virtualNetworks_sample_vnet_name}/public-subnet'
  properties: {
    addressPrefixes: addressPrefixes_public_subnet_address_prefixes
    ipamPoolPrefixAllocations: [
      {
        numberOfIpAddresses: '8'
        pool: {
          id: networkManagers_sample_vnet_network_manager_name_sample_vnet_ipv4_pool.id
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroups_sample_public_nsg_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
  dependsOn: [
    virtualNetworks_sample_vnet_name_resource
  ]
}
