param serverName string
param dbName string
param kvName string
param rgKvName string
@secure()
param sqlAdminLogin string
@secure()
param passwordAdmin string



var connectionString = 'Data Source=tcp:${serverName}.database.windows.net,1433;Initial Catalog=${dbName};User ID=${sqlAdminLogin}@${serverName};Password=${passwordAdmin};Trusted_Connection=False;Encrypt=True;Connection Timeout=30'

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
  scope: resourceGroup(subscription().subscriptionId,rgKvName) 
}

resource insertSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'insertConnectionString'
  parent: kv
  properties: {
  }
}
