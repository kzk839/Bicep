param resourceNamePrefix string
param location string = resourceGroup().location
param adminUserName string

@secure()
param adminUserPassword string
param numberOfWindows int
param numberOfUbuntu int

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: '${resourceNamePrefix}-vnet'
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
  name: '${resourceNamePrefix}-NSG-1'
  location: location
  properties: {
    securityRules: [

    ]
  }
}

resource NSG2 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${resourceNamePrefix}-NSG-2'
  location: location
  properties: {
    securityRules: [

    ]
  }
}

resource NSG3 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${resourceNamePrefix}-NSG-3'
  location: location
  properties: {
    securityRules: [

    ]
  }
}

module WinVmModule '../module/deploy-windows.bicep' = [for i in range(0, numberOfWindows): {
  name: '${resourceNamePrefix}-winVmDeploy${padLeft(i+1, 3, '0')}'
  params: {
    adminPassword: adminUserPassword
    adminUserName: adminUserName
    location: location
    vmName: '${resourceNamePrefix}-WinVM${padLeft(i+1, 3, '0')}'
    subnetId: vnet::Subnet1.id
    vmSize: 'Standard_B2ms'
  }
}]

module UbuVmModule '../module/deploy-ubuntu.bicep' = [for i in range(0, numberOfUbuntu): {
  name: '${resourceNamePrefix}-ubuVmDeploy${padLeft(i+1, 3, '0')}'
  params: {
    adminPassword: adminUserPassword
    adminUserName: adminUserName
    location: location
    vmName: '${resourceNamePrefix}-UbuVM${padLeft(i+1, 3, '0')}'
    subnetId: vnet::Subnet2.id
    vmSize: 'Standard_B1ms'
  }
}]
