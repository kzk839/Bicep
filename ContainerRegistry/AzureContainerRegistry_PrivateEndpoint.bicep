param location string = resourceGroup().location

param VNetName string

param SubnetName string

@minLength(5)
@maxLength(50)
param acrName string

param acrSku string = 'Premium'

resource VNet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: VNetName
  resource Subnet 'subnets' existing = {
    name: SubnetName
  }
}

resource ACR 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Disabled'
  }
}

resource AcrPe 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: '${acrName}-PE'
  location : location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${acrName}-PE-Con'
        properties: {
          privateLinkServiceId: ACR.id
          groupIds: [
            'registry'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: VNet::Subnet.id
    }
  }
}
