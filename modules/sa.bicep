
@description('Specifies the Azure location where the resources should be created.')
param location string

@description('the different names of the containers')
param containerNames array


@description('component name used for resource name')
param partName string 

param tags object

var nameSa = 'sa${toLower(replace(partName,'-',''))}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01'={
	name: nameSa
	location: location
	tags:tags
	sku: {
		name:'Standard_LRS'
	}
  properties: {
    isHnsEnabled: true
  }
	kind: 'StorageV2'

  resource blobServices 'blobServices@2023-01-01' = if (!empty(containerNames)) {
    name: 'default'
    properties: {
    }

    resource blobContainers 'containers@2023-01-01' = [for item in containerNames: {
      name:item.name
      properties:{
      publicAccess:'None'
      }
    }]
  }
}



output storageName string = storageAccount.name
output idStorage string = storageAccount.id
output endpointUri string = storageAccount.properties.primaryEndpoints.dfs
