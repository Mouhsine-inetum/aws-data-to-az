param adfName string

@description('This is the built-in storage blob reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource storageContributeRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}


resource adfRBAC 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, adf.name, 'adfRBAC')
  scope: resourceGroup()
  properties: {
    principalId: adf.identity.principalId
    roleDefinitionId: storageContributeRoleDefinition.id
    principalType: 'ServicePrincipal'
  }
}
