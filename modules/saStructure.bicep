param location string
param directories array
param storageAccountName string
param containerName string
param muaiName string

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource deploymentScriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: muaiName
}
resource createDirectory 'Microsoft.Resources/deploymentScripts@2023-08-01' = [for item in directories: if (length(directories) > 0) {
  name: 'createDirectory-${item}'
  location: location
  kind: 'AzureCLI'
  identity: {
     type: 'UserAssigned'
     userAssignedIdentities:{
      '${deploymentScriptIdentity.id}': {}
     }
  }
  properties: {
    azCliVersion: '2.57.0'
    retentionInterval: 'P1D'
    arguments: '\'${storageAccountName}\' \'${containerName}\' \'${item}\''
    scriptContent: 'az storage fs directory create --account-name ${storageAccountName} -f ${containerName} -n ${item}'
  }
}
]

