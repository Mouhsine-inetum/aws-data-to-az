@description('component name used for resource name')
param partName string 

@description('role definition id')
param storageDataRoleDefinitionId string


@description('principal id to will be given access to the resouurce')
param principalId string

var storageServiceName = 'sa${toLower(replace(partName,'-',''))}'


var storageDataRoleAssignmentName = guid(storageBlobService.id , principalId, storageDataRoleDefinitionId)


resource storageBlobService 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageServiceName
}

resource contributeRoleAssignmentForStorage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: storageDataRoleAssignmentName
  scope: storageBlobService
  properties: {
    roleDefinitionId: storageDataRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}




