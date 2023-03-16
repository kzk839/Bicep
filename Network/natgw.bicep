param location string = resourceGroup().location

param NatGwName string

@allowed([
  '1'
  '2'
  '3'
])
param zone string

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
