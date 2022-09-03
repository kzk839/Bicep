param location string = resourceGroup().location

param VNetName string

param SubnetName string

param Storage_Name string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param Storage_SKU string


resource VNet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: VNetName
  resource Subnet 'subnets' existing = {
    name: SubnetName
  }
}

resource Storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: Storage_Name
  location: location
  sku: {
    name: Storage_SKU
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

resource StoragePe 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: '${Storage_Name}-PE'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${Storage_Name}-PE-Con'
        properties: {
          groupIds: [
            'blob'
          ]
          privateLinkServiceId: Storage.id
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
