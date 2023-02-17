@description('description')
param VmName string = 'BacklogJumpBox'

@description('Username for the Virtual Machine.')
param AdminUserName string

@description('Password for the Virtual Machine.')
@secure()
param AdminPassword string

@description('Your Global IP Address for RDP')
param YourGlobalIpAddress string

var location = resourceGroup().location
var nic_name_var = '${VmName}-nic'
var ip_name_var = '${VmName}-ip'
var vnet_name_var = 'BacklogJumpboxVnet'
var subnet1_name = '${vnet_name_var}-Subnet1'
var nsg_name_var = '${subnet1_name}-NSG'

resource ip_name 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: ip_name_var
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource vnet_name 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnet_name_var
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnet1_name
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource vnet_name_subnet1_name 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  parent: vnet_name
  name: '${subnet1_name}'
  properties: {
    addressPrefix: '10.0.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    networkSecurityGroup: {
      id: nsg_name.id
    }
  }
}

resource VmName_resource 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: VmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      dataDisks: []
    }
    osProfile: {
      computerName: VmName
      adminUsername: AdminUserName
      adminPassword: AdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic_name.id
        }
      ]
    }
  }
}

resource nic_name 'Microsoft.Network/networkInterfaces@2020-03-01' = {
  name: nic_name_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: ip_name.id
          }
          subnet: {
            id: vnet_name_subnet1_name.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource nsg_name 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsg_name_var
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'nsgRule1'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: YourGlobalIpAddress
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}