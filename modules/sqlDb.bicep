param location string

param tag object

@description('Specifies sql admin login')
@secure()
param sqlAdministratorLogin string


@minLength(8)
@description('password of the admin for the sql server access')
@secure()
param  sqlAdministratorPassword string 


@description('component name used for resource name')
param partName string 

var sqlServerName= 'ssdb-${partName}'
var databaseName = 'sdb-${partName}'


// Data resources
resource sqlserver 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  tags: tag
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    version: '12.0'
    // publicNetworkAccess:'Disabled'
  }

  resource database 'databases@2023-05-01-preview' = {
    name: databaseName
    tags: tag
    location: location
    sku: {
      name: 'Basic'
    }
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      maxSizeBytes: 1073741824
    }
  }

  resource firewallRule 'firewallRules@2023-05-01-preview' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      endIpAddress: '0.0.0.0'
      startIpAddress: '0.0.0.0'
    }
    
  }
}


