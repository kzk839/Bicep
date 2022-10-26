param nsgNamePrefix string
param locatioin string = resourceGroup().location
param repeatNumber int

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = [for i in range(0,repeatNumber): {
  name: '${nsgNamePrefix}-NSG-${padLeft(i, 3, '0')}'
  location: locatioin
}]
