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
  'Standard_D2ds_v5'
  'Standard_D4ds_v5'
  'Standard_D8ds_v5'
  'Standard_D16ds_v5'
  'Standard_D32ds_v5'
  'Standard_D48ds_v5'
  'Standard_D64ds_v5'
  'Standard_D96ds_v5'
  'Standard_D2ds_v4'
  'Standard_D4ds_v4'
  'Standard_D8ds_v4'
  'Standard_D16ds_v4'
  'Standard_D32ds_v4'
])
param generalPurposeVmSize string

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

@allowed([
  'Disabled'
  'SameZone'
  'ZoneRedundant'
])
param highAvailabilityMode string

@maxValue(35)
@minValue(7)
param backupRetentionDays int = 7

@allowed([
  'Disabled'
  'Enabled'
])
param geoRedundantBackup string

@allowed([
  'Any'
  '1'
  '2'
  '3'
])
param availabilityZone string

@allowed([
  '1'
  '2'
  '3'
])
param secondaryAvailabilityZone string

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
    name: generalPurposeVmSize
    tier: 'GeneralPurpose'
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
      mode: highAvailabilityMode
      standbyAvailabilityZone: highAvailabilityMode == 'ZoneRedundant' ? secondaryAvailabilityZone : null
    }
    storage: {
      storageSizeGB: intStorageSize
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    availabilityZone: availabilityZone == 'Any' ? null : availabilityZone
  }
}
