param location string

@description('component name used for resource name')
param partName string 

@description('name of the container to be created')
param nameOfContainer string

param tags object

// @description('name of the in value binded trigger')
// param bindingName string 

var functionAppName = 'fa-${partName}'
var appServicePlanName = 'as-${partName}'
var functionRuntime = 'node'
var storageAccountName = 'sa${toLower(replace(partName,'-',''))}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource plan 'Microsoft.Web/serverfarms@2023-01-01'  =  {
  name: appServicePlanName
  location: location
  tags: tags
}

var endpoint = '${storageAccount.properties.primaryEndpoints.blob}/${nameOfContainer}'
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  tags:tags
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountname'
          value: storageAccount.name
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name:'EndpointToBlob'

          value: endpoint
        }
        {
          name:'Name'
          value: nameOfContainer
        }
      ]
    }
    httpsOnly: true
  }
  
}



resource appToStorageRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}






output functionPrincipal string = functionApp.identity.principalId
output roleDefinitionForAppToStorage string = appToStorageRoleDefinition.id

output functionId string = functionApp.id
output functionAppHostName string = functionApp.properties.defaultHostName
output functionName string = functionApp.name
