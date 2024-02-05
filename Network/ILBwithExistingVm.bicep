param nicName string = 'Demo-NIC1'
param vNetName string = 'Demo-VNet'
param subnetName string = 'LB-Subnet1'
param ilbName string = 'Demo-ILB1'
param ilbFrontendIP string = '10.4.2.20'
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' existing = {
  name: vNetName
  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

resource ilb 'Microsoft.Network/loadBalancers@2023-06-01' = {
  name: ilbName
  location: location
  properties:{
    frontendIPConfigurations: [
      {
        name: 'FrontendIPConfiguration1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: ilbFrontendIP
          subnet: {
            id: vnet::subnet.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendAddressPool1'
      }
    ]
    probes: [
      {
        name: 'probe1'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', ilbName, 'FrontendIPConfiguration1')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', ilbName, 'BackendAddressPool1')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', ilbName, 'probe1')
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name : 'ipconfig1'
        properties: {
          subnet: {
            id: vnet::subnet.id
          }
          loadBalancerBackendAddressPools:[
            {
              id : ilb.properties.backendAddressPools[0].id
            }
          ]
        }
      }
    ]
  }
}
