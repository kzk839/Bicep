param location string = resourceGroup().location

var blobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

resource NSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'NSG'
  location: location
  properties: {
    securityRules: [

    ]
  }
}

resource VNet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'VNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '172.16.0.0/24'
          networkSecurityGroup: {
            id: NSG.id
          }
        }
      }
    ]
  }
  resource Subnet1 'Subnets' existing = {
    name: 'Subnet-1'
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'kkflowtestsa'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

resource storagePE 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: 'storageblobpe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'storageblobpecon'
        properties: {
          groupIds: [
            'blob'
          ]
          privateLinkServiceId: storage.id
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: VNet::Subnet1.id
    }
  }
}

resource blobPricateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${storagePE.name}/blob-PrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: blobPrivateDnsZoneName
        properties: {
          privateDnsZoneId: blobPricateDnsZone.id
        }
      }
    ]
  }
}

resource blobPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${blobPricateDnsZone.name}/${uniqueString(storage.id)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: VNet.id
    }
  }
}
