param location string
param partName string


var dfName= 'df-${partName}'

resource dataFatory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dfName
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
  }
  identity: {
    type:  'SystemAssigned'
  }
}

output datafactoryName string = dataFatory.name
