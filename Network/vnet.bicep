param vNetname string
param location string = resourceGroup().location
@description('Enter the address prefix up to the second octet Example: 10.0')
param addressPrefix string = '10.0'

var addressSpace = '${addressPrefix}.0.0/16'

resource vNet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vNetname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '${addressPrefix}.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '${addressPrefix}.1.0/24'
        }
      }
      {
        name: 'Subnet-3'
        properties: {
          addressPrefix: '${addressPrefix}.2.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '${addressPrefix}.253.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '${addressPrefix}.254.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '${addressPrefix}.255.0/24'
        }
      }
    ]
  }
}
