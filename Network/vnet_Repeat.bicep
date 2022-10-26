param vNetNamePrefix string
param location string = resourceGroup().location
@description('Enter the address prefix up to the second octet Example: 10.0')
param addressPrefix string = '10.0'
param repeatNumber int

var addressSpace = '${addressPrefix}.0.0/16'

resource vNet 'Microsoft.Network/virtualNetworks@2021-05-01' = [for i in range(0,  repeatNumber):  {
  name: '${vNetNamePrefix}-VNet-${padLeft(i, 3, '0')}'
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
    ]
  }
}]
