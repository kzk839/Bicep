param location string = resourceGroup().location
param adminUserName string = 'UserName'

param kvName string = 'KeyVaultName'
param secretName string = 'SecretName'

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'vnet'
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
            id: NSG1.id
          }
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '172.16.1.0/24'
          networkSecurityGroup: {
            id: NSG2.id
          }
        }
      }
      {
        name: 'Subnet-3'
        properties: {
          addressPrefix: '172.16.3.0/24'
          networkSecurityGroup: {
            id: NSG3.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '172.16.253.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '172.16.254.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '172.16.255.0/24'
        }
      }
    ]
  }
  resource Subnet1 'subnets' existing = {
    name: 'Subnet-1'
  }
  resource Subnet2 'subnets' existing = {
    name: 'Subnet-2'
  }
  resource Subnet3 'subnets' existing = {
    name: 'Subnet-3'
  }
}

resource NSG1 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'NSG-1'
  location: location
  properties: {
    securityRules: [

    ]
  }
}

resource NSG2 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'NSG-2'
  location: location
  properties: {
    securityRules: [

    ]
  }
}

resource NSG3 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'NSG-3'
  location: location
  properties: {
    securityRules: [

    ]
  }
}

resource NIC1 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'NIC-1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '172.16.0.4'
          subnet: {
            id: vnet::Subnet1.id
          }
        }
      }
    ]
  }
}

resource NIC2 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'NIC-2'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '172.16.1.4'
          subnet: {
            id: vnet::Subnet2.id
          }
        }
      }
    ]
  }
}

resource KeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: kvName
  scope: resourceGroup('kkRGP')
}

module WinVmModule '../module/deploy-windows.bicep' = {
  name: 'winVmDeploy'
  params: {
    adminPassword: KeyVault.getSecret(secretName)
    adminUserName: adminUserName
    location: location
    nicId: NIC1.id
    vmName: 'WinVM1'
  }
}

module UbuVmModule '../module/deploy-ubuntu.bicep' = {
  name: 'ubuVmDeploy'
  params: {
    adminPassword: KeyVault.getSecret(secretName)
    adminUserName: adminUserName
    location: location
    nicId: NIC2.id
    vmName: 'UbuVM1'
  }
}
