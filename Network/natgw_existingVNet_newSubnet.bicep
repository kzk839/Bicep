param location string = resourceGroup().location

param NatGwName string

@allowed([
  '1'
  '2'
  '3'
])
param zone string

param vNetName string

resource vNet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vNetName
  resource subnet 'subnets' = {
    name: 'AzureNatGW-Subnet'
    properties: {
      addressPrefix: '10.8.10.0/24'
      natGateway: {
        id: NatGw.id
      }
    }
  }
}

resource NatGwPublicIP 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: '${NatGwName}-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  zones: [
    zone
  ]
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

resource NatGw 'Microsoft.Network/natGateways@2022-09-01' = {
  name: NatGwName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: [
    zone
  ]
  properties: {
    publicIpAddresses: [
      {
        id: NatGwPublicIP.id
      }
    ]
    idleTimeoutInMinutes: 4
  }
}
