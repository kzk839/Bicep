param vNet1name string

param vNet1Location string = resourceGroup().location

@description('Enter the address prefix up to the second octet Example: 10.0')
param vNet1AddressPrefix string = '10.0'

param vNet2name string

param vNet2Location string = resourceGroup().location

@description('Enter the address prefix up to the second octet Example: 10.0')
param vNet2AddressPrefix string = '10.1'

var vNet1AddressSpace = '${vNet1AddressPrefix}.0.0/16'
var vNet2AddressSpace = '${vNet2AddressPrefix}.0.0/16'

resource vNet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vNet1name
  location: vNet1Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNet1AddressSpace
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '${vNet1AddressPrefix}.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '${vNet1AddressPrefix}.1.0/24'
        }
      }
      {
        name: 'Subnet-3'
        properties: {
          addressPrefix: '${vNet1AddressPrefix}.2.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '${vNet1AddressPrefix}.253.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '${vNet1AddressPrefix}.254.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '${vNet1AddressPrefix}.255.0/24'
        }
      }
    ]
  }
}

resource vNet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vNet2name
  location: vNet2Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNet2AddressSpace
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '${vNet2AddressPrefix}.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '${vNet2AddressPrefix}.1.0/24'
        }
      }
      {
        name: 'Subnet-3'
        properties: {
          addressPrefix: '${vNet2AddressPrefix}.2.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '${vNet2AddressPrefix}.253.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '${vNet2AddressPrefix}.254.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '${vNet2AddressPrefix}.255.0/24'
        }
      }
    ]
  }
}

resource vNet1tovNet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'VNet1toVNet2'
  parent: vNet1
  properties:{
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways:false
    remoteVirtualNetwork: {
      id: vNet2.id
    }
  }
}

resource vNet2tovNet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: 'VNet2toVNet1'
  parent: vNet2
  properties:{
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways:false
    remoteVirtualNetwork: {
      id: vNet1.id
    }
  }
}
