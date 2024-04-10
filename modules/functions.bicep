param functionAppName string
param functionName string

resource funcApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: functionAppName
}

resource functionNodeStaging 'Microsoft.Web/sites/functions@2023-01-01' = {
  name: functionName
  parent: funcApp
  properties: {
    config: {
      bindings:[
        {
          name: 'myBlob'
          type: 'blobTrigger'
          direction: 'in'
          path: 'input/landing'
          connection: 'azsavehiculesdata_STORAGE'
        }
        {
          name: 'stagingFolder'
          direction: 'out'
          type: 'blob'
          path: 'input/staging/{rand-guid}.json'
          methods: []
          connection: 'azsavehiculesdata_STORAGE'
        }
        {
          name: 'rejectedFolder'
          direction: 'out'
          type: 'blob'
          path: 'input/rejected/{rand-guid}.json'
          methods: []
          connection: 'azsavehiculesdata_STORAGE'
        }
      ]
    }
    files:{
      'index.js': loadTextContent('../functions/transfer_to_staging.js')
    }
  }
}
