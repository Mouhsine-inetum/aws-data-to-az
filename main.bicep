param location string
param partName string
param containersSet array
param tags object
param containerName string
@secure()
param accessKeyId string
@secure()
param accessKeySecret string
@secure()
param sqlAdminUser string
@secure()
param sqlAdminPasswd string

param connectionString string


var PipelineFolderStructure= '@formatDateTime(utcNow(), \'yyyy//MM//dd\')'
module sa_module 'modules/sa.bicep'  = {
  name: 'storageAccountDeployment'
  params: {
    containerNames: containersSet
    location: location
    partName: partName
    tags: tags
  }
}


module userAssignedIdentity 'modules/userAssignedIdentity.bicep' = {
  name: 'muaiDeployment'
  params: {
    location: location 
  }
}

module saStrusture_module 'modules/saStructure.bicep'  = [for (item, index) in containersSet: {
  name:'storageAccountStructureDeploylment_${index}'
  params: {
    muaiName: userAssignedIdentity.outputs.uaiName
    location: location
    containerName: item.name
    directories: item.directories
    storageAccountName: sa_module.outputs.storageName
  }
  dependsOn: [sa_module, userAssignedIdentity]
}]


module datafactory 'modules/dataFactory.bicep' = {
  name: 'dataFactoryDeployment'
  params: {
    location: location
    partName: partName
  }
}

module dataFactoryRoleAssign 'modules/dataFactoryRoleAssignment.bicep' = {
  name: 'dataFactoryAssignment'
  params: {
    adfName: datafactory.outputs.datafactoryName
  }
}

// resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
//   name: kvName
//   scope: resourceGroup(subscription().subscriptionId,rgKvName) 
// }


module dataFactoryPipelines_copy_aws_to_az 'modules/dataFactoryPipelines.bicep' = {
  name: 'dfPipelinesDeployment'
  params: {
    dataFactoryName: datafactory.outputs.datafactoryName
    location: location
    partName: partName
    pipeline: 'vehicule_data_from_aws_to_az'
    dsSettings:[
      {
        name: 'ds_az_blob'
        type: 'Json'
        linkedService: {
          referenceName: 'ls_az_blob'
          type: 'LinkedServiceReference'
        }
        parameters: {
          landingFolder:{
            type: 'String'
          }
        }
        typeProperties: {
          location: {
            type: 'AzureBlobFSLocation'
            folderPath: '@dataset().landingFolder'
            fileSystem: 'input'
          }
        }
        schema:{}
      }

      {
        name: 'ds_aws_s3'
        type: 'Json'
        linkedService: {
          referenceName: 'ls_aws_s3'
          type: 'LinkedServiceReference'
        }
        parameters: {
          folderPath:{
            type: 'String'
          }
        }
        typeProperties: {
          location: {
            type: 'AmazonS3Location'
            bucketName: 'iotdatafromudemy'
            folderPath: '@dataset().folderPath'
          }
        }
        schema:{}
      }
    ]
    lsSettings: [
      {
        name:'ls_aws_s3'
        type: 'AmazonS3'
        typeProperties: {
          accessKeyId:accessKeyId
          secretAccessKey: accessKeySecret
        }
      }

      {
        name:'ls_az_blob'
        type: 'AzureBlobFS'
        typeProperties: {
          url: sa_module.outputs.endpointUri
        }
      }
    ]
    pipeSettings: [
      {
        name:'copy_data_from_awsBucket_to_azStorageBlob'
        type: 'Copy'
        dependsOn: []
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        typeProperties: {
          source: {
            type: 'JsonSource'
            storeSettings: {
              type: 'AmazonS3ReadSettings'
              recursive: true
              enablePartitionDiscovery: false
              wildcardFileName: '*.json'
            }
            formatSettings: {
              type: 'JsonReadSettings'
            }
          }
          sink: {
            type: 'JsonSink'
            storeSettings: {
              type: 'AzureBlobFSWriteSettings'
            }
            formatSettings: {
              type: 'JsonWriteSettings'
            }
          }
          enableStaging: false

        }
        inputs: [
          {
            referenceName: 'ds_aws_s3'
            type: 'DatasetReference'
            parameters: {
              folderPath: '${PipelineFolderStructure}'
            }
          }
        ]
        outputs:[
          {
            referenceName: 'ds_az_blob'
            type: 'DatasetReference'
            parameters: {
              landingFolder : '@concat(\'landing//\',formatDateTime(utcNow(),\'yyyy\'),\'/\',formatDateTime(utcNow(),\'MM\'),\'/\',formatDateTime(utcNow(),\'dd\'))'
            }
          }
        ]
      }
    ]
    
    
  }
  dependsOn:[dataFactoryRoleAssign]
}


module sqlServerDatabase 'modules/sqlDb.bicep' = {
  name: 'sqlserverDbDeployment'
  params: {
    location: location
    partName: partName
    sqlAdministratorLogin: sqlAdminUser
    sqlAdministratorPassword: sqlAdminPasswd
    tag: tags
  }
}



module dataFactoryPipelines_copy_blob_to_sql 'modules/dataFactoryPipelines.bicep' = {
  name: 'dfPipelinesDeployment_copy_blob_to_sql'
  params: {
    dataFactoryName: datafactory.outputs.datafactoryName
    location: location
    partName: partName
    pipeline: 'vehicule_data_from_blob_to_sqlTable'
    dsSettings:[ // here-----------------------------------------------------------------------------------
      {
        name: 'ds_az_staging_blob'
        type: 'Json'
        linkedService: {
          referenceName: 'ls_az_blob'
          type: 'LinkedServiceReference'
        }
        parameters: {}
        typeProperties: {
          location: {
            type: 'AzureBlobFSLocation'
            folderPath: 'staging'
            fileSystem: 'input'
          }
        }
        schema: [
                  {
                    name: 'CustomerID'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'NameStyle'
                    type: 'String'
                    physicalType: 'Boolean'
                  }
                  {
                    name: 'Title'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'FirstName'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'MiddleName'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'LastName'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'Suffix'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'CompanyName'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'SalesPerson'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'EmailAddress'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'Phone'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'PasswordHash'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'PasswordSalt'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'rowguid'
                    type: 'String'
                    physicalType: 'String'
                  }
                  {
                    name: 'ModifiedDate'
                    type: 'String'
                    physicalType: 'String'
                  }
                ]
      }

      {
        name: 'ds_az_sql'
        type: 'AzureSqlTable'
        linkedService: {
          referenceName: 'ls_az_sql'
          type: 'LinkedServiceReference'
        }
        parameters: {
        }
        typeProperties: {
          schema: 'dbo'
          table: 'vehiculedata'
        }
        schema:[
                  {
                    name: 'VehiculeId'
                    type: 'String'
                    physicalType: 'nvarchar'
                  }
                  {
                    name: 'latitude'
                    type: 'Decimal'
                    precision: 18
                    scale: 0
                    physicalType: 'decimal'
                  }
                  {
                    name: 'longitude'
                    type: 'Decimal'
                    precision: 18
                    scale: 0
                    physicalType: 'decimal'
                  }
                  {
                    name: 'city'
                    type: 'String'
                    physicalType: 'nvarchar'
                  }
                  {
                    name: 'temparatue'
                    type: 'Integer'
                    precision: 10
                    physicalType: 'int'
                  }
                  {
                    name: 'speed'
                    type: 'Integer'
                    precision: 10
                    physicalType: 'int'
                  }
                ]
      }
    ]
    lsSettings: [// done-----------------------------------------------------------------------------------
      {
        name:'ls_az_sql'
        type: 'AzureSqlDatabase'
        typeProperties: {
          connectionString: connectionString
        }
      }


    ]
    pipeSettings: [
      {
        name:'copy_data_from_azStorageBlob_to_sqlTable'
        type: 'Copy'
        dependsOn: []
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        typeProperties: {
          source: {
            type: 'JsonSource'
            storeSettings: {
              type: 'AzureBlobFSReadSettings'
              recursive: true
              enablePartitionDiscovery: false
              wildcardFileName: '*.json'
            }
            formatSettings: {
              type: 'JsonReadSettings'
            }
          }
          sink: {
            type: 'AzureSqlSink'
            writeBehavior: 'insert'
            sqlWriterUseTableLock: false
          }
          enableStaging: false

        }
        inputs: [
          {
            referenceName: 'ds_az_staging_blob'
            type: 'DatasetReference'
          }
        ]
        outputs:[
          {
            referenceName: 'ds_az_sql'
            type: 'DatasetReference'
          }
        ]
      }
    ]
    
    
  }
  dependsOn:[dataFactoryRoleAssign, sqlServerDatabase]
}


module funcationApp 'modules/functionApp.bicep' = {
  name: 'functionAppDeployment'
  params: {
    location: location
    nameOfContainer: containerName 
    partName: partName
    tags: tags
  }
  dependsOn:[sa_module]
}

module funcationAppRoleAss 'modules/functionAppRoleAssignment.bicep' = {
  name: 'functionAppRoleAssignment'
  params: {
    partName: partName
    principalId: funcationApp.outputs.functionPrincipal
    storageDataRoleDefinitionId: funcationApp.outputs.roleDefinitionForAppToStorage
  }
}

module functionCreation 'modules/functions.bicep' = {
  name: 'functionsDeployment'
  params: {
    functionAppName: funcationApp.outputs.functionName
    functionName: 'fu-vehdata-transferstaging'
  }
}
