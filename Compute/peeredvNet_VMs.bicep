param resourceNamePrefix string

param location1 string = resourceGroup().location

param location2 string = resourceGroup().location

param adminUserName string

@secure()
param adminUserPassword string

resource vNet1 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: '${resourceNamePrefix}-vnet1'
  location: location1
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '172.20.0.0/24'
          networkSecurityGroup: {
            id: vNet1_NSG1.id
          }
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '172.20.1.0/24'
          networkSecurityGroup: {
            id: vNet1_NSG2.id
          }
        }
      }
      {
        name: 'Subnet-3'
        properties: {
          addressPrefix: '172.20.3.0/24'
          networkSecurityGroup: {
            id: vNet1_NSG3.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '172.20.253.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '172.20.254.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '172.20.255.0/24'
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

resource vNet1_NSG1 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: '${resourceNamePrefix}-vNet1-NSG1'
  location: location1
  properties: {
    securityRules: [

    ]
  }
}

resource vNet1_NSG2 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: '${resourceNamePrefix}-vNet1-NSG2'
  location: location1
  properties: {
    securityRules: [

    ]
  }
}

resource vNet1_NSG3 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: '${resourceNamePrefix}-vNet1-NSG3'
  location: location1
  properties: {
    securityRules: [

    ]
  }
}

module vNet1_WinVm '../module/deploy-windows.bicep' = {
  name: '${resourceNamePrefix}-winVmDeploy1'
  params: {
    adminPassword: adminUserPassword
    adminUserName: adminUserName
    location: location1
    vmName: '${resourceNamePrefix}-WinVM1'
    subnetId: vNet1::Subnet1.id
    vmSize: 'Standard_B2ms'
  }
}

resource vNet2 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: '${resourceNamePrefix}-vnet2'
  location: location2
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.30.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '172.30.0.0/24'
          networkSecurityGroup: {
            id: vNet2_NSG1.id
          }
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '172.30.1.0/24'
          networkSecurityGroup: {
            id: NSG2.id
          }
        }
      }
      {
        name: 'Subnet-3'
        properties: {
          addressPrefix: '172.30.3.0/24'
          networkSecurityGroup: {
            id: NSG3.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '172.30.253.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '172.30.254.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '172.30.255.0/24'
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

resource vNet2_NSG1 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: '${resourceNamePrefix}-vNet2-NSG1'
  location: location2
  properties: {
    securityRules: [

    ]
  }
}

resource NSG2 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: '${resourceNamePrefix}-vNet2-NSG2'
  location: location2
  properties: {
    securityRules: [

    ]
  }
}

resource NSG3 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: '${resourceNamePrefix}-vNet2-NSG3'
  location: location2
  properties: {
    securityRules: [

    ]
  }
}

module vNet2_WinVM '../module/deploy-windows.bicep' = {
  name: '${resourceNamePrefix}-winVmDeploy2'
  params: {
    adminPassword: adminUserPassword
    adminUserName: adminUserName
    location: location1
    vmName: '${resourceNamePrefix}-WinVM2'
    subnetId: vNet2::Subnet1.id
    vmSize: 'Standard_B2ms'
  }
}

resource vNet1_to_vNet2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-09-01' = {
  name: 'vNet1-to-vNet2'
  parent: vNet1
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vNet2.id
    }
  }
}

resource vNet2_to_vNet1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-09-01' = {
  name: 'vNet2-to-vNet1'
  parent: vNet2
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vNet1.id
    }
  }
}
