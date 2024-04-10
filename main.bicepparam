using 'main.bicep'

param location = 'westeurope'
param partName = 'ud-test-dev-01'
param containersSet = [
 {
  name: 'logs'
  directories: []
 }
 {
  name : 'input'
  directories: [
  'landing'
  'staging'
  'rejected'
]
 }
]

param tags = {
  project: 'ud-test'
  version: 01
  env : 'dev'
  location: 'europe'
}

param accessKeyId = getSecret('0f7a3b62-c1a4-4aa9-97c3-3bf5f497b5ab','cloud-shell-storage-westeurope','kvfoodeliverywesteurope','s3accesskeyid')
param accessKeySecret = getSecret('0f7a3b62-c1a4-4aa9-97c3-3bf5f497b5ab','cloud-shell-storage-westeurope','kvfoodeliverywesteurope','s3accesskeysecret')
param containerName = 'input'
param sqlAdminPasswd = getSecret('0f7a3b62-c1a4-4aa9-97c3-3bf5f497b5ab','cloud-shell-storage-westeurope','kvfoodeliverywesteurope','sqlPasswordAdmin')
param sqlAdminUser = getSecret('0f7a3b62-c1a4-4aa9-97c3-3bf5f497b5ab','cloud-shell-storage-westeurope','kvfoodeliverywesteurope','sqlUserLogin')
param connectionString = getSecret('0f7a3b62-c1a4-4aa9-97c3-3bf5f497b5ab','cloud-shell-storage-westeurope','kvfoodeliverywesteurope','sqlconnectionString')

