param location string
param partName string
param lsSettings array
param dsSettings array
param pipeSettings array
param dataFactoryName string 
param pipeline string



var pipelineName = 'pipe-${pipeline}'


resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}



resource adfLs 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = [for item in lsSettings: {
  parent: adf
  name: item.name
  properties: {
  type: item.type
  typeProperties: item.typeProperties
  }
}]






resource adfDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = [for item in dsSettings: {
  parent: adf
  name: item.name
  properties: {
    type: item.type
    linkedServiceName: item.linkedService
    parameters: item.parameters
    typeProperties: item.typeProperties
    schema : item.schema
  }
  dependsOn: adfLs
}]




resource adfPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: adf
  name: pipelineName
  properties: {
  activities: [for item in pipeSettings: {
    name: item.name
    type: item.type
    dependsOn: item.dependsOn
    policy: item.policy
    typeProperties: item.typeProperties
    inputs: item.inputs
    outputs: item.outputs
  }
  ]
  }
  dependsOn: [
    adfDataset
  ]
}

