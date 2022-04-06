
param location string = resourceGroup().location

param vmname string
param adminusername string = 'kkuser'
@secure()
param adminpassword string

param vnetresourcegroupname string
param vnetname string
param subnetname string
param privateip string

var vnetId = resourceId(vnetresourcegroupname, 'Microsoft.Network/virtualNetworks', vnetname)
var subnetRef = '${vnetId}/subnets/${subnetname}'

resource networkinterface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${vmname}-nic'
  location: location
  properties:{
    ipConfigurations:[
      {
        name: 'ipconfig'
        properties:{
          primary: true
          privateIPAddressVersion:'IPv4'
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateip
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
}

resource virtualmachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmname
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      adminUsername: adminusername
      adminPassword: adminpassword
      computerName: vmname
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
        deleteOption: 'Delete'
        name: '${vmname}-osdisk'
        osType: 'Windows'
      }
    }
    networkProfile: {
      networkInterfaces:[
        {
          id: networkinterface.id
        }
      ]
    }
  }
}
