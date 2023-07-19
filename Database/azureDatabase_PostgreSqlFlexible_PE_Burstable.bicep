param location string = resourceGroup().location

@maxLength(63)
param serverName string

@allowed([
  '14'
  '13'
  '12'
  '11'
])
param postgreSqlVersion string

@allowed([
  'Standard_B1ms'
  'Standard_B2s'
  'Standard_B2ms'
  'Standard_B4ms'
  'Standard_B8ms'
  'Standard_B12ms'
  'Standard_B16ms'
  'Standard_B20ms'
])
param burstableVmSize string

@allowed([
  '32 GiB'
  '64 GiB'
  '128 GiB'
  '256 GiB'
  '512 GiB'
  '1 TiB'
  '2 TiB'
  '4 TiB'
  '8 TiB'
  '16 TiB'
  '32 TiB'
])
param storageSize string

@maxValue(35)
@minValue(7)
param backupRetentionDays int = 7

@allowed([
  'Disabled'
  'Enabled'
])
param geoRedundantBackup string

param administratorName string

@secure()
param administratorPassword string

param vnetName string

param subnetName string

param privateDnsZoneResourceId string

var intStorageSize = int(split(storageSize, ' ')[0])

resource postgreSqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: serverName
  location: location
  sku: {
    name: burstableVmSize
    tier: 'Burstable'
  }
  properties: {
    version: postgreSqlVersion
    administratorLogin: administratorName
    administratorLoginPassword: administratorPassword
    network: {
      delegatedSubnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
      privateDnsZoneArmResourceId: privateDnsZoneResourceId
    }
    highAvailability: {
      mode: 'Disabled'
    }
    storage: {
      storageSizeGB: intStorageSize
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    availabilityZone: null
  }
}
