@description('Resovery Services Vault Name')
param vaultName string

@description('Recovery Services Vault, VNet, Private Endpoint Location')
param location string = resourceGroup().location

@description('Existing Virtual Network Name')
param vnetName string

@description('Subnet Name')
param subnetName string

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-10-01' = {
  name: vaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource vNet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: '${vaultName}-PE'
  location: location
  properties: {
    subnet:{
      id: vNet::subnet.id
    }
    privateLinkServiceConnections:[
      {
        name: '${vaultName}-PE-Connection'
        properties:{
          groupIds:[
            'AzureBackup'
          ]
          privateLinkServiceId:recoveryServicesVault.id
        }
      }
    ]
  }
}
