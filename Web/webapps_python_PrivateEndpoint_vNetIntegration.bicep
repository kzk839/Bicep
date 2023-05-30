param location string = resourceGroup().location

@minLength(2)
@maxLength(60)
param appServiceName string

@allowed([
  'Python 3.11'
  'Python 3.10'
  'Python 3.9'
  'Python 3.8'
])
param runtimeStack string

@allowed([
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P1V2'
  'P2V2'
  'P3V2'
  'P0V3'
  'P1V3'
  'P2V3'
  'P3V3'
])
param appServicePlanSku string

@allowed([
  'Linux'
])
param os string = 'Linux'

@allowed([
  true
  false
])
param enableZoneRedundancy bool

param privateEndpointVnetName string
param privateEndpointSubnetName string
param integrationVnetName string
param integrationSubnetName string

var appServicePlanName = '${appServiceName}-Plan'
var linuxFxVersion = (runtimeStack == 'Python 3.11') ? 'PYTHON|3.11' : (runtimeStack == 'Python 3.10') ? 'PYTHON|3.10' : (runtimeStack == 'Python 3.9') ? 'PYTHON|3.9' : 'PYTHON|3.8'

resource privateEndpointVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: privateEndpointVnetName
  resource privateEndpointSubnet 'subnets' existing = {
    name: privateEndpointSubnetName
  }
}

resource integrationVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: integrationVnetName
  resource integrationSubnet 'subnets' existing = {
    name: integrationSubnetName
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
  }
  kind: os
  properties: {
    zoneRedundant: enableZoneRedundancy
    reserved: (os == 'Linux') ? true : false
  }
}

resource webAppSite 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  properties: {
    siteConfig: {
      linuxFxVersion: (os == 'Linux') ? linuxFxVersion : null
      alwaysOn: true
      ftpsState: 'FtpsOnly'
    }
    vnetRouteAllEnabled: true
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: true
    virtualNetworkSubnetId: integrationVnet::integrationSubnet.id
    httpsOnly: true
    publicNetworkAccess: 'Disabled'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: '${appServiceName}-PE'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${appServiceName}-PE-Con'
        properties: {
          privateLinkServiceId: webAppSite.id
          groupIds: [
            'sites'
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
      id: privateEndpointVnet::privateEndpointSubnet.id
    }
  }
}
