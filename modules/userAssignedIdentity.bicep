param location string

resource deploymentScriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'deploymentScriptIdentity'
  location: location
}

@description('This is the built-in storage blob reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource storageContributeRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}

resource dsRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, deploymentScriptIdentity.name, 'dsRBAC')
  scope: resourceGroup()
  properties: {
    principalId: deploymentScriptIdentity.properties.principalId
    roleDefinitionId: storageContributeRoleDefinition.id
    principalType: 'ServicePrincipal'
  }
}

output uaiName string = deploymentScriptIdentity.name
