param location string = resourceGroup().location

param onPremiseVnetName string = 'onPremiseVnet'

param hubVnetName string = 'hubVnet'

param spokeVnet1Name string = 'spokeVnet1'

param spokeVNet2Name string = 'spokeVNet2'

param onpremVm1Name string = 'onpremVm1'

param hubVm1Name string = 'hubVm1'

param spoke1Vm1Name string = 'spokeVm1'

param spoke2Vm1Name string = 'spokeVm2'

param user string

@secure()
param password string

param vmSize string = 'Standard_B1s'

param sharedKey string

//------------------------------------------------------------
resource onPremiseVnet_Gateway_Ip 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: '${onPremiseVnetName}-Gateway-Ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource hubVnet_Gateway_Ip 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: '${hubVnetName}-Gateway-Ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource onPremiseSubnet1_NSG 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: '${onPremiseVnetName}-Subnet1-NSG'
  location: location
  properties: {
    securityRules: []
  }
}

resource hubSubnet1_NSG 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: '${hubVnetName}-Subnet1-NSG'
  location: location
  properties: {
    securityRules: []
  }
}

resource spoke1Subnet1_NSG 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: '${spokeVnet1Name}-Subnet1-NSG'
  location: location
  properties: {
    securityRules: []
  }
}

resource spoke2Subnet1_NSG 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: '${spokeVNet2Name}-Subnet1-NSG'
  location: location
  properties: {
    securityRules: []
  }
}

resource onPremiseVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: onPremiseVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: onPremiseSubnet1_NSG.id
          }
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.255.0/24'
        }
      }
    ]
  }
  resource onPremiseSubnet1 'subnets' existing = {
    name: 'Subnet-1'
  }
  resource onPremiseGatewaySubnet 'subnets' existing = {
    name: 'GatewaySubnet'
  }
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '192.168.0.0/24'
          networkSecurityGroup: {
            id: hubSubnet1_NSG.id
          }
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '192.168.255.0/24'
        }
      }
    ]
  }
  resource hubSubnet1 'subnets' existing = {
    name: 'Subnet-1'
  }
  resource hubGatewaySubnet 'subnets' existing = {
    name: 'GatewaySubnet'
  }
}

resource spokeVnet1 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: spokeVnet1Name
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
            id: spoke1Subnet1_NSG.id
          }
        }
      }
    ]
  }
  resource spoke1Subnet1 'subnets' existing = {
    name: 'Subnet-1'
  }
}

resource spokeVNet2 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: spokeVNet2Name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.17.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '172.17.0.0/24'
          networkSecurityGroup: {
            id: spoke2Subnet1_NSG.id
          }
        }
      }
    ]
  }
  resource spoke2Subnet1 'subnets' existing = {
    name: 'Subnet-1'
  }
}

resource onPremiseVnetGw 'Microsoft.Network/virtualNetworkGateways@2023-02-01' = {
  name: '${onPremiseVnetName}-Gw'
  location: location
  properties: {
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    ipConfigurations: [
      {
        name: 'gwipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: onPremiseVnet::onPremiseGatewaySubnet.id
          }
          publicIPAddress: {
            id: onPremiseVnet_Gateway_Ip.id
          }
        }
      }
    ]
    bgpSettings: {
      asn: 65020
    }
    gatewayType: 'Vpn'
    vpnGatewayGeneration: 'Generation1'
  }
}

resource hubVnetGw 'Microsoft.Network/virtualNetworkGateways@2023-02-01' = {
  name: '${hubVnetName}-Gw'
  location: location
  properties: {
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    ipConfigurations: [
      {
        name: 'gwipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: hubVnet::hubGatewaySubnet.id
          }
          publicIPAddress: {
            id: hubVnet_Gateway_Ip.id
          }
        }
      }
    ]
    bgpSettings: {
      asn: 65010
    }
    gatewayType: 'Vpn'
    vpnGatewayGeneration: 'Generation1'
  }
}

resource spoke1ToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: '${spokeVnet1Name}-to-${hubVnetName}'
  parent: spokeVnet1
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
  dependsOn: [
    hubVnetGw
  ]
}

resource hubToSpoke1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: '${hubVnetName}-to-${spokeVnet1Name}'
  parent: hubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVnet1.id
    }
  }
  dependsOn: [
    hubVnetGw
  ]
}

resource spoke2ToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: '${spokeVNet2Name}-to-${hubVnetName}'
  parent: spokeVNet2
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
  dependsOn: [
    hubVnetGw
  ]
}

resource hubToSpoke2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-02-01' = {
  name: '${hubVnetName}-to-${spokeVNet2Name}'
  parent: hubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVNet2.id
    }
  }
  dependsOn: [
    hubVnetGw
  ]
}

resource onPremiseLocalNetworkGateway 'Microsoft.Network/localNetworkGateways@2023-02-01' = {
  name: '${onPremiseVnetName}-LocalGateway'
  location: location
  properties: {
    bgpSettings: {
      asn: 65020
      bgpPeeringAddress: onPremiseVnetGw.properties.bgpSettings.bgpPeeringAddress
    }
    gatewayIpAddress: onPremiseVnet_Gateway_Ip.properties.ipAddress
  }
}

resource hubLocalNetworkGateway 'Microsoft.Network/localNetworkGateways@2023-02-01' = {
  name: '${hubVnetName}-LocalGateway'
  location: location
  properties: {
    bgpSettings: {
      asn: 65010
      bgpPeeringAddress: hubVnetGw.properties.bgpSettings.bgpPeeringAddress
    }
    gatewayIpAddress: hubVnet_Gateway_Ip.properties.ipAddress
  }
}

resource onPremiseToHubConnection 'Microsoft.Network/connections@2023-02-01' = {
  name: '${onPremiseVnetName}-to-${hubVnetName}'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: onPremiseVnetGw.id
      properties: {}
    }
    localNetworkGateway2: {
      id: hubLocalNetworkGateway.id
      properties: {}
    }
    connectionType: 'IPsec'
    routingWeight: 0
    sharedKey: sharedKey
    enableBgp: true
    usePolicyBasedTrafficSelectors: false
  }
}

resource hubToOnPremiseConnection 'Microsoft.Network/connections@2023-02-01' = {
  name: '${hubVnetName}-to-${onPremiseVnetName}'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: hubVnetGw.id
      properties: {}
    }
    localNetworkGateway2: {
      id: onPremiseLocalNetworkGateway.id
      properties: {}
    }
    connectionType: 'IPsec'
    routingWeight: 0
    sharedKey: sharedKey
    enableBgp: true
    usePolicyBasedTrafficSelectors: false
  }
}

module onpremiseVm1 '../module/deploy-ubuntu20_04.bicep' = {
  name: onpremVm1Name
  params: {
    adminPassword: password
    adminUserName: user
    location: location
    subnetId: onPremiseVnet::onPremiseSubnet1.id
    vmName: onpremVm1Name
    vmSize: vmSize
  }
}

module hubVm1 '../module/deploy-ubuntu20_04.bicep' = {
  name: hubVm1Name
  params: {
    adminPassword: password
    adminUserName: user
    location: location
    subnetId: onPremiseVnet::onPremiseSubnet1.id
    vmName: hubVm1Name
    vmSize: vmSize
  }
}

module spoke1Vm1 '../module/deploy-ubuntu20_04.bicep' = {
  name: spoke1Vm1Name
  params: {
    adminPassword: password
    adminUserName: user
    location: location
    subnetId: spokeVnet1::spoke1Subnet1.id
    vmName: spoke1Vm1Name
    vmSize: vmSize
  }
}

module spoke2Vm1 '../module/deploy-ubuntu20_04.bicep' = {
  name: spoke2Vm1Name
  params: {
    adminPassword: password
    adminUserName: user
    location: location
    subnetId: spokeVNet2::spoke2Subnet1.id
    vmName: spoke2Vm1Name
    vmSize: vmSize
  }
}
