param location string = resourceGroup().location

@minLength(2)
@maxLength(60)
param appServiceName string

@allowed([
  'Java 17'
  'Java 11'
])
param runtimeStack string

@allowed([
  'Java SE (Embedded Web Server)'
  'Apache Tomcat 10.0'
  'Apache Tomcat 9.0'
  'Apache Tomcat 8.5'
])
param javaWebServerStack string

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
  'Windows'
])
param os string

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
var webserver = (javaWebServerStack == 'Java SE (Embedded Web Server)') ? 'JAVA|' : (javaWebServerStack == 'Apache Tomcat 10.0') ? 'TOMCAT|10.0' : (javaWebServerStack == 'Apache Tomcat 9.0') ? 'TOMCAT|9.0' : 'TOMCAT|8.5'
var runtime = (runtimeStack == 'Java 17') ? '-java17' : '-java11'
var linuxFxVersion = (javaWebServerStack == 'Java SE (Embedded Web Server)') ? '${webserver}${javaVersion}${runtime}' : '${webserver}${runtime}'
var javaVersion = (runtimeStack == 'Java 17') ? '17' : '11'
var javaContainer = (javaWebServerStack == 'Java SE (Embedded Web Server)') ? 'Java' : 'TOMCAT'
var javaContainerVersion = (javaWebServerStack == 'Java SE (Embedded Web Server)') ? 'SE' : (javaWebServerStack == 'Apache Tomcat 10.0') ? '10.0' : (javaWebServerStack == 'Apache Tomcat 9.0') ? '9.0' : '8.5'

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
      metadata: [
        {
          name: (os == 'Windows') ? 'CURRENT_STACK' : null
          value: (os == 'Windows') ? 'java' : null
        }
      ]
      linuxFxVersion: (os == 'Linux') ? linuxFxVersion : null
      javaVersion: (os == 'Windows') ? javaVersion : null
      javaContainer: (os == 'Windows') ? javaContainer : null
      javaContainerVersion: (os == 'Windows') ? javaContainerVersion : null
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
