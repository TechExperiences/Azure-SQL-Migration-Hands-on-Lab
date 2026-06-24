targetScope = 'resourceGroup'

@description('Optional suffix used in resource names. If empty, a deterministic suffix is generated.')
@maxLength(12)
param suffix string = ''

@description('Used for deterministic naming when suffix is not provided.')
param runDateTime string = utcNow()

@description('Generated suffix length when suffix is not provided.')
@minValue(1)
@maxValue(32)
param generatedSuffixLength int = 10

@description('Length of the normalized resource-group token used in generated names.')
@minValue(1)
@maxValue(64)
param rgTokenLength int = 12

@description('Deployment attempt label used in generated names.')
param deploymentAttemptLabel string = 'f1'

@description('Primary location for SQL and DMS resources.')
param location string = resourceGroup().location

@description('Deploy Azure SQL Server + Database resources.')
param deploySql bool = true

@description('Deploy Azure Database Migration Service resource.')
param deployDms bool = true

@description('Location for Azure SQL resources.')
param sqlLocation string = location

@description('Location for Azure Database Migration Service.')
param dmsLocation string = location

@description('Create a dedicated VNet/subnet for SQL Migration Service.')
param deployDmsNetwork bool = true

@description('Azure SQL Server admin login.')
param sqlAdminLogin string = 'sqladmin'

@description('Azure SQL Server admin password.')
@secure()
param sqlAdminPassword string

@description('Azure SQL Server version.')
param sqlServerVersion string = '12.0'

@description('SQL Server public network access setting.')
@allowed([
  'Enabled'
  'Disabled'
])
param sqlPublicNetworkAccess string = 'Enabled'

@description('Azure SQL Database-**Hyperscale** SKU name.')
param sqlDatabaseSkuName string = 'Basic'

@description('Azure SQL Database-**Hyperscale** SKU tier.')
param sqlDatabaseSkuTier string = 'Basic'

@description('Azure SQL Database-**Hyperscale** SKU capacity.')
@minValue(1)
param sqlDatabaseSkuCapacity int = 5

@description('Azure SQL requested backup storage redundancy.')
param sqlBackupStorageRedundancy string = 'Local'

var normalizedSuffix = toLower(empty(suffix) ? take(uniqueString(subscription().id, resourceGroup().id, runDateTime), generatedSuffixLength) : suffix)
var rgToken = take(toLower(replace(resourceGroup().name, '-', '')), rgTokenLength)

@description('Azure SQL Server name.')
param sqlServerName string = ''

@description('Azure SQL Database-**Hyperscale** name.')
param sqlDatabaseName string = ''

@description('Azure Database Migration Service name.')
param dmsServiceName string = ''

@description('DMS VNet name. If empty, a generated name is used.')
param dmsVnetName string = ''

@description('DMS VNet address prefix.')
param dmsVnetAddressPrefix string = '10.250.0.0/16'

@description('DMS subnet name.')
param dmsSubnetName string = 'snet-dms'

@description('DMS subnet address prefix.')
param dmsSubnetAddressPrefix string = '10.250.1.0/24'

var effectiveSqlServerName = empty(sqlServerName) ? 'sql-${rgToken}-${deploymentAttemptLabel}-${normalizedSuffix}' : sqlServerName
var effectiveSqlDatabaseName = empty(sqlDatabaseName) ? 'sqldb-${rgToken}-${deploymentAttemptLabel}-${normalizedSuffix}' : sqlDatabaseName
var effectiveDmsServiceName = empty(dmsServiceName) ? 'dms-${rgToken}-${deploymentAttemptLabel}-${normalizedSuffix}' : dmsServiceName
var effectiveDmsVnetName = empty(dmsVnetName) ? 'vnet-dms-${rgToken}-${deploymentAttemptLabel}-${normalizedSuffix}' : dmsVnetName

resource dmsVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = if (deployDms && deployDmsNetwork) {
  name: effectiveDmsVnetName
  location: dmsLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        dmsVnetAddressPrefix
      ]
    }
  }
}

resource dmsSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = if (deployDms && deployDmsNetwork) {
  parent: dmsVnet
  name: dmsSubnetName
  properties: {
    addressPrefix: dmsSubnetAddressPrefix
  }
}

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = if (deploySql) {
  name: effectiveSqlServerName
  location: sqlLocation
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: sqlServerVersion
    publicNetworkAccess: sqlPublicNetworkAccess
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = if (deploySql) {
  parent: sqlServer
  name: effectiveSqlDatabaseName
  location: sqlLocation
  sku: {
    name: sqlDatabaseSkuName
    tier: sqlDatabaseSkuTier
    capacity: sqlDatabaseSkuCapacity
  }
  properties: {
    requestedBackupStorageRedundancy: sqlBackupStorageRedundancy
  }
}

// SQL Migration Service (new DMS) resource.
resource dmsService 'Microsoft.DataMigration/SqlMigrationServices@2025-06-30' = if (deployDms) {
  name: effectiveDmsServiceName
  location: dmsLocation
  tags: {
    dmsNetworkMode: deployDmsNetwork ? 'dedicated-vnet' : 'none'
    dmsSubnetResourceId: (deployDms && deployDmsNetwork) ? dmsSubnet.id : 'none'
  }
}

output suffixUsed string = normalizedSuffix
output sqlServerName string = deploySql ? sqlServer.name : ''
output sqlServerId string = deploySql ? sqlServer.id : ''
output sqlDatabaseName string = deploySql ? sqlDatabase.name : ''
output sqlLocation string = sqlLocation
output dmsServiceName string = deployDms ? dmsService.name : ''
output dmsServiceId string = deployDms ? dmsService.id : ''
output dmsLocation string = dmsLocation
output dmsVnetName string = (deployDms && deployDmsNetwork) ? dmsVnet.name : ''
output dmsSubnetId string = (deployDms && deployDmsNetwork) ? dmsSubnet.id : ''


