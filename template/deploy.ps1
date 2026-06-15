param(
    [string]$EnvFilePath = (Join-Path $PSScriptRoot ".env"),
    [string]$TemplateFileName = "",
    [string]$ResourceGroupName = "",
    [string]$Location = "",
    [string]$Suffix = "",
    [string]$SqlAdminLogin = "",
    [int]$SqlAdminPasswordLength = 0,
    [string]$SqlPasswordCharset = "",
    [string]$SqlCredentialsDir = "",
    [string[]]$SqlRegionCandidates = @(),
    [string[]]$DmsRegionCandidates = @(),
    [string]$DmsVirtualSubnetId = "",
    [string]$DmsSkuName = "",
    [string]$DmsSkuTier = "",
    [string]$SqlServerVersion = "",
    [string]$SqlPublicNetworkAccess = "",
    [string]$SqlClientFirewallRulePrefix = "",
    [string]$SqlDatabaseSkuName = "",
    [string]$SqlDatabaseSkuTier = "",
    [int]$SqlDatabaseSkuCapacity = 0,
    [string]$SqlBackupStorageRedundancy = "",
    [int]$DeploymentPollIntervalSeconds = 0,
    [int]$DeploymentTimeoutMinutes = 0,
    [string]$DmsVnetNamePrefix = "",
    [string]$DmsVnetAddressPrefix = "",
    [string]$DmsSubnetName = "",
    [string]$DmsSubnetAddressPrefix = "",
    [string]$DmsAlternateSubnetName = "",
    [string]$DmsAlternateSubnetAddressPrefix = "",
    [string[]]$PublicIpSources = @(),
    [string]$AzureServicesFirewallRuleName = "",
    [string]$AutoResourceGroupNamePrefix = "",
    [int]$AutoResourceGroupRandomMax = 0,
    [int]$SuffixRandomMin = 0,
    [int]$SuffixRandomMax = 0,
    [string]$SuffixFallbackText = "",
    [int]$CustomSuffixMaxBaseLength = 0,
    [string]$SuffixTimeFormat = "",
    [int]$RgTokenMaxLength = 0,
    [string]$RgTokenFallbackText = "",
    [string]$DefaultRegionIfNone = "",
    [string]$CredentialsFilePrefix = "",
    [string]$CredentialsTimestampFormat = "",
    [string]$CredentialsCreatedOnUtcFormat = "",
    [string]$SqlServerNameTemplate = "",
    [string]$SqlDatabaseNameTemplate = "",
    [string]$DmsServiceNameTemplate = "",
    [int]$SqlServerNameMaxLength = 0,
    [int]$SqlDatabaseNameMaxLength = 0,
    [int]$DmsServiceNameMaxLength = 0
    ,
    [int]$BicepGeneratedSuffixLength = 0,
    [int]$BicepRgTokenLength = 0,
    [string]$BicepDeploymentAttemptLabel = "",
    [string]$BicepRunDateTime = "",
    [string]$SqlDeploymentPrefix = "",
    [string]$DmsDeploymentPrefix = "",
    [string]$SqlDeploymentLabel = "",
    [string]$DmsDeploymentLabel = "",
    [string]$SqlResourceType = "",
    [string]$DmsResourceType = "",
    [string]$SqlLocationParamName = "",
    [string]$DmsLocationParamName = "",
    [string]$SqlOutputResourceNameKey = "",
    [string]$DmsOutputResourceNameKey = "",
    [bool]$DeploySqlForSqlStep = $false,
    [bool]$DeployDmsForSqlStep = $false,
    [bool]$DeploySqlForDmsStep = $false,
    [bool]$DeployDmsForDmsStep = $false
)

$ErrorActionPreference = "Stop"
$script:CliBoundParameters = @{}
foreach ($k in $PSBoundParameters.Keys) {
    $script:CliBoundParameters[$k] = $true
}

function Read-EnvFile {
    param([string]$Path)

    $settings = @{}
    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
        return $settings
    }

    foreach ($rawLine in (Get-Content -LiteralPath $Path)) {
        if ([string]::IsNullOrWhiteSpace($rawLine)) {
            continue
        }

        $line = $rawLine.Trim()
        if ($line.StartsWith("#")) {
            continue
        }

        $eq = $line.IndexOf("=")
        if ($eq -lt 1) {
            continue
        }

        $key = $line.Substring(0, $eq).Trim()
        $value = $line.Substring($eq + 1).Trim()
        if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
            if ($value.Length -ge 2) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($key)) {
            $settings[$key] = $value
        }
    }

    return $settings
}

function Set-ParamFromEnvString {
    param([hashtable]$Settings, [string]$ParamName, [string]$EnvKey)

    if ($script:CliBoundParameters.ContainsKey($ParamName)) { return }
    if (-not $Settings.ContainsKey($EnvKey)) { return }
    Set-Variable -Name $ParamName -Scope Script -Value $Settings[$EnvKey]
}

function Set-ParamFromEnvInt {
    param([hashtable]$Settings, [string]$ParamName, [string]$EnvKey)

    if ($script:CliBoundParameters.ContainsKey($ParamName)) { return }
    if (-not $Settings.ContainsKey($EnvKey)) { return }

    $parsed = 0
    if (-not [int]::TryParse([string]$Settings[$EnvKey], [ref]$parsed)) {
        throw "Invalid integer value for $EnvKey in env file."
    }

    Set-Variable -Name $ParamName -Scope Script -Value $parsed
}

function Set-ParamFromEnvArray {
    param([hashtable]$Settings, [string]$ParamName, [string]$EnvKey)

    if ($script:CliBoundParameters.ContainsKey($ParamName)) { return }
    if (-not $Settings.ContainsKey($EnvKey)) { return }

    $value = [string]$Settings[$EnvKey]
    $items = @(
        $value -split "[,;]" |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
    Set-Variable -Name $ParamName -Scope Script -Value $items
}

function Set-ParamFromEnvBool {
    param([hashtable]$Settings, [string]$ParamName, [string]$EnvKey)

    if ($script:CliBoundParameters.ContainsKey($ParamName)) { return }
    if (-not $Settings.ContainsKey($EnvKey)) { return }

    $value = [string]$Settings[$EnvKey]
    $parsed = $false
    if (-not [bool]::TryParse($value, [ref]$parsed)) {
        throw "Invalid boolean value for $EnvKey in env file. Use true/false."
    }

    Set-Variable -Name $ParamName -Scope Script -Value $parsed
}

$envSettings = Read-EnvFile -Path $EnvFilePath

Set-ParamFromEnvString -Settings $envSettings -ParamName "TemplateFileName" -EnvKey "TEMPLATE_FILE_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "ResourceGroupName" -EnvKey "RESOURCE_GROUP_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "Location" -EnvKey "LOCATION"
Set-ParamFromEnvString -Settings $envSettings -ParamName "Suffix" -EnvKey "SUFFIX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlAdminLogin" -EnvKey "SQL_ADMIN_LOGIN"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "SqlAdminPasswordLength" -EnvKey "SQL_ADMIN_PASSWORD_LENGTH"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlPasswordCharset" -EnvKey "SQL_PASSWORD_CHARSET"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlCredentialsDir" -EnvKey "SQL_CREDENTIALS_DIR"
Set-ParamFromEnvArray  -Settings $envSettings -ParamName "SqlRegionCandidates" -EnvKey "SQL_REGION_CANDIDATES"
Set-ParamFromEnvArray  -Settings $envSettings -ParamName "DmsRegionCandidates" -EnvKey "DMS_REGION_CANDIDATES"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsVirtualSubnetId" -EnvKey "DMS_VIRTUAL_SUBNET_ID"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsSkuName" -EnvKey "DMS_SKU_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsSkuTier" -EnvKey "DMS_SKU_TIER"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlServerVersion" -EnvKey "SQL_SERVER_VERSION"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlPublicNetworkAccess" -EnvKey "SQL_PUBLIC_NETWORK_ACCESS"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlClientFirewallRulePrefix" -EnvKey "SQL_CLIENT_FIREWALL_RULE_PREFIX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlDatabaseSkuName" -EnvKey "SQL_DATABASE_SKU_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlDatabaseSkuTier" -EnvKey "SQL_DATABASE_SKU_TIER"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "SqlDatabaseSkuCapacity" -EnvKey "SQL_DATABASE_SKU_CAPACITY"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlBackupStorageRedundancy" -EnvKey "SQL_BACKUP_STORAGE_REDUNDANCY"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "DeploymentPollIntervalSeconds" -EnvKey "DEPLOYMENT_POLL_INTERVAL_SECONDS"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "DeploymentTimeoutMinutes" -EnvKey "DEPLOYMENT_TIMEOUT_MINUTES"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsVnetNamePrefix" -EnvKey "DMS_VNET_NAME_PREFIX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsVnetAddressPrefix" -EnvKey "DMS_VNET_ADDRESS_PREFIX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsSubnetName" -EnvKey "DMS_SUBNET_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsSubnetAddressPrefix" -EnvKey "DMS_SUBNET_ADDRESS_PREFIX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsAlternateSubnetName" -EnvKey "DMS_ALT_SUBNET_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsAlternateSubnetAddressPrefix" -EnvKey "DMS_ALT_SUBNET_ADDRESS_PREFIX"
Set-ParamFromEnvArray  -Settings $envSettings -ParamName "PublicIpSources" -EnvKey "PUBLIC_IP_SOURCES"
Set-ParamFromEnvString -Settings $envSettings -ParamName "AzureServicesFirewallRuleName" -EnvKey "AZURE_SERVICES_FIREWALL_RULE_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "AutoResourceGroupNamePrefix" -EnvKey "AUTO_RESOURCE_GROUP_NAME_PREFIX"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "AutoResourceGroupRandomMax" -EnvKey "AUTO_RESOURCE_GROUP_RANDOM_MAX"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "SuffixRandomMin" -EnvKey "SUFFIX_RANDOM_MIN"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "SuffixRandomMax" -EnvKey "SUFFIX_RANDOM_MAX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SuffixFallbackText" -EnvKey "SUFFIX_FALLBACK_TEXT"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "CustomSuffixMaxBaseLength" -EnvKey "CUSTOM_SUFFIX_MAX_BASE_LENGTH"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SuffixTimeFormat" -EnvKey "SUFFIX_TIME_FORMAT"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "RgTokenMaxLength" -EnvKey "RG_TOKEN_MAX_LENGTH"
Set-ParamFromEnvString -Settings $envSettings -ParamName "RgTokenFallbackText" -EnvKey "RG_TOKEN_FALLBACK_TEXT"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DefaultRegionIfNone" -EnvKey "DEFAULT_REGION_IF_NONE"
Set-ParamFromEnvString -Settings $envSettings -ParamName "CredentialsFilePrefix" -EnvKey "CREDENTIALS_FILE_PREFIX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "CredentialsTimestampFormat" -EnvKey "CREDENTIALS_TIMESTAMP_FORMAT"
Set-ParamFromEnvString -Settings $envSettings -ParamName "CredentialsCreatedOnUtcFormat" -EnvKey "CREDENTIALS_CREATED_UTC_FORMAT"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlServerNameTemplate" -EnvKey "SQL_SERVER_NAME_TEMPLATE"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlDatabaseNameTemplate" -EnvKey "SQL_DATABASE_NAME_TEMPLATE"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsServiceNameTemplate" -EnvKey "DMS_SERVICE_NAME_TEMPLATE"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "SqlServerNameMaxLength" -EnvKey "SQL_SERVER_NAME_MAX_LENGTH"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "SqlDatabaseNameMaxLength" -EnvKey "SQL_DATABASE_NAME_MAX_LENGTH"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "DmsServiceNameMaxLength" -EnvKey "DMS_SERVICE_NAME_MAX_LENGTH"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "BicepGeneratedSuffixLength" -EnvKey "BICEP_GENERATED_SUFFIX_LENGTH"
Set-ParamFromEnvInt    -Settings $envSettings -ParamName "BicepRgTokenLength" -EnvKey "BICEP_RG_TOKEN_LENGTH"
Set-ParamFromEnvString -Settings $envSettings -ParamName "BicepDeploymentAttemptLabel" -EnvKey "BICEP_DEPLOYMENT_ATTEMPT_LABEL"
Set-ParamFromEnvString -Settings $envSettings -ParamName "BicepRunDateTime" -EnvKey "BICEP_RUN_DATETIME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlDeploymentPrefix" -EnvKey "SQL_DEPLOYMENT_PREFIX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsDeploymentPrefix" -EnvKey "DMS_DEPLOYMENT_PREFIX"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlDeploymentLabel" -EnvKey "SQL_DEPLOYMENT_LABEL"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsDeploymentLabel" -EnvKey "DMS_DEPLOYMENT_LABEL"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlResourceType" -EnvKey "SQL_RESOURCE_TYPE"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsResourceType" -EnvKey "DMS_RESOURCE_TYPE"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlLocationParamName" -EnvKey "SQL_LOCATION_PARAM_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsLocationParamName" -EnvKey "DMS_LOCATION_PARAM_NAME"
Set-ParamFromEnvString -Settings $envSettings -ParamName "SqlOutputResourceNameKey" -EnvKey "SQL_OUTPUT_RESOURCE_NAME_KEY"
Set-ParamFromEnvString -Settings $envSettings -ParamName "DmsOutputResourceNameKey" -EnvKey "DMS_OUTPUT_RESOURCE_NAME_KEY"
Set-ParamFromEnvBool   -Settings $envSettings -ParamName "DeploySqlForSqlStep" -EnvKey "DEPLOY_SQL_FOR_SQL_STEP"
Set-ParamFromEnvBool   -Settings $envSettings -ParamName "DeployDmsForSqlStep" -EnvKey "DEPLOY_DMS_FOR_SQL_STEP"
Set-ParamFromEnvBool   -Settings $envSettings -ParamName "DeploySqlForDmsStep" -EnvKey "DEPLOY_SQL_FOR_DMS_STEP"
Set-ParamFromEnvBool   -Settings $envSettings -ParamName "DeployDmsForDmsStep" -EnvKey "DEPLOY_DMS_FOR_DMS_STEP"

function New-UniqueSuffix {
    param([string]$RequestedSuffix)

    $randUpperExclusive = $SuffixRandomMax + 1
    $rand = (Get-Random -Minimum $SuffixRandomMin -Maximum $randUpperExclusive).ToString()
    $timePart = (Get-Date).ToUniversalTime().ToString($SuffixTimeFormat)

    if (-not [string]::IsNullOrWhiteSpace($RequestedSuffix)) {
        $clean = ($RequestedSuffix.ToLower() -replace "[^a-z0-9]", "")
        if ([string]::IsNullOrWhiteSpace($clean)) {
            $clean = $SuffixFallbackText
        }
        $base = if ($clean.Length -gt $CustomSuffixMaxBaseLength) { $clean.Substring(0, $CustomSuffixMaxBaseLength) } else { $clean }
        return "$base$rand"
    }

    return "$timePart$rand"
}

function Get-RgToken {
    param([string]$RgName)

    $token = ($RgName.ToLower() -replace "[^a-z0-9]", "")
    if ([string]::IsNullOrWhiteSpace($token)) {
        return $RgTokenFallbackText
    }

    if ($token.Length -gt $RgTokenMaxLength) {
        return $token.Substring(0, $RgTokenMaxLength)
    }

    return $token
}

function Build-NameFromTemplate {
    param(
        [Parameter(Mandatory = $true)] [string]$Template,
        [Parameter(Mandatory = $true)] [string]$RgToken,
        [Parameter(Mandatory = $true)] [string]$SuffixValue,
        [Parameter(Mandatory = $true)] [int]$Attempt
    )

    $name = $Template.Replace("{rgToken}", $RgToken)
    $name = $name.Replace("{suffix}", $SuffixValue)
    $name = $name.Replace("{attempt}", [string]($Attempt + 1))
    return $name
}

function Convert-BoolToBicepString {
    param([bool]$Value)
    if ($Value) { return "true" }
    return "false"
}

function Invoke-AzProbe {
    param(
        [Parameter(Mandatory = $true)] [string[]]$Arguments,
        [switch]$SuppressStderr
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $hasNativePref = $false
    $previousNativePref = $null

    if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
        $hasNativePref = $true
        $previousNativePref = $PSNativeCommandUseErrorActionPreference
    }

    try {
        $ErrorActionPreference = "Continue"
        if ($hasNativePref) {
            $global:PSNativeCommandUseErrorActionPreference = $false
        }

        if ($SuppressStderr) {
            $output = & az @Arguments 2>$null
        } else {
            $output = & az @Arguments
        }
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
        if ($hasNativePref) {
            $global:PSNativeCommandUseErrorActionPreference = $previousNativePref
        }
    }

    return @{
        Output = $output
        ExitCode = $exitCode
    }
}

function Resolve-BicepRunDateTime {
    param([string]$ConfiguredValue)

    if ([string]::IsNullOrWhiteSpace($ConfiguredValue)) {
        throw "BicepRunDateTime cannot be empty."
    }

    if ($ConfiguredValue -eq "__AUTO_UTC_NOW__") {
        return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }

    $parsed = $null
    if (-not [DateTime]::TryParse($ConfiguredValue, [ref]$parsed)) {
        throw "BicepRunDateTime must be a valid datetime string or '__AUTO_UTC_NOW__'."
    }

    return $ConfiguredValue
}

function Get-SqlServerName {
    param([string]$RgToken, [string]$SuffixValue, [int]$Attempt = 0)
    $name = Build-NameFromTemplate -Template $SqlServerNameTemplate -RgToken $RgToken -SuffixValue $SuffixValue -Attempt $Attempt
    if ($name.Length -gt $SqlServerNameMaxLength) { return $name.Substring(0, $SqlServerNameMaxLength) }
    return $name
}

function Get-SqlDatabaseName {
    param([string]$RgToken, [string]$SuffixValue, [int]$Attempt = 0)
    $name = Build-NameFromTemplate -Template $SqlDatabaseNameTemplate -RgToken $RgToken -SuffixValue $SuffixValue -Attempt $Attempt
    if ($name.Length -gt $SqlDatabaseNameMaxLength) { return $name.Substring(0, $SqlDatabaseNameMaxLength) }
    return $name
}

function Get-DmsServiceName {
    param([string]$RgToken, [string]$SuffixValue, [int]$Attempt = 0)
    $name = Build-NameFromTemplate -Template $DmsServiceNameTemplate -RgToken $RgToken -SuffixValue $SuffixValue -Attempt $Attempt
    if ($name.Length -gt $DmsServiceNameMaxLength) { return $name.Substring(0, $DmsServiceNameMaxLength) }
    return $name
}

function Get-PreferredRegions {
    param(
        [string[]]$Candidates,
        [string]$Fallback
    )

    $ordered = New-Object System.Collections.Generic.List[string]

    foreach ($candidate in @($Candidates)) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        $normalized = $candidate.Trim().ToLower()
        if (-not $ordered.Contains($normalized)) {
            $ordered.Add($normalized)
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($Fallback)) {
        $fallbackNormalized = $Fallback.Trim().ToLower()
        if (-not $ordered.Contains($fallbackNormalized)) {
            $ordered.Add($fallbackNormalized)
        }
    }

    if ($ordered.Count -eq 0) {
        $ordered.Add($DefaultRegionIfNone)
    }

    return @($ordered)
}

function Get-VNetAndSubnetFromSubnetId {
    param(
        [Parameter(Mandatory = $true)] [string]$SubnetId
    )

    $pattern = "^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\.Network/virtualNetworks/(?<vnet>[^/]+)/subnets/(?<subnet>[^/]+)$"
    $match = [System.Text.RegularExpressions.Regex]::Match($SubnetId, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (-not $match.Success) {
        throw "Invalid subnet resource ID format: $SubnetId"
    }

    return @{
        vnetName = $match.Groups["vnet"].Value
        subnetName = $match.Groups["subnet"].Value
    }
}

function Get-DmsSubnetMetadata {
    param(
        [Parameter(Mandatory = $true)] [string]$SubnetId
    )

    $parts = Get-VNetAndSubnetFromSubnetId -SubnetId $SubnetId
    $vnetName = $parts.vnetName
    $subnetName = $parts.subnetName

    $subnetJson = az network vnet subnet show `
        --ids $SubnetId `
        --query "{id:id,delegations:delegations,vnetId:id}" `
        --output json `
        --only-show-errors

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve subnet by ID: $SubnetId"
    }

    $subnet = $subnetJson | ConvertFrom-Json
    $delegated = $false
    foreach ($delegation in @($subnet.delegations)) {
        if ($delegation.serviceName -eq "Microsoft.DataMigration/services") {
            $delegated = $true
            break
        }
    }

    $vnetId = [string]$subnet.vnetId
    if ($vnetId -match "/subnets/[^/]+$") {
        $vnetId = $vnetId -replace "/subnets/[^/]+$", ""
    }

    $vnetRegionRaw = az network vnet show `
        --ids $vnetId `
        --query "location" `
        --output tsv `
        --only-show-errors

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to determine region for VNet backing subnet: $SubnetId"
    }

    return @{
        subnetId = [string]$subnet.id
        region = $vnetRegionRaw.Trim().ToLower()
        delegated = $delegated
        vnetName = $vnetName
        subnetName = $subnetName
    }
}

function Find-DelegatedDmsSubnetInResourceGroup {
    param(
        [Parameter(Mandatory = $true)] [string]$ResourceGroup,
        [Parameter(Mandatory = $true)] [string[]]$PreferredRegions
    )

    $vnetProbe = Invoke-AzProbe -Arguments @(
        "network", "vnet", "list",
        "--resource-group", $ResourceGroup,
        "--query", "[].{name:name,location:location}",
        "--output", "json",
        "--only-show-errors"
    ) -SuppressStderr

    if ($vnetProbe.ExitCode -ne 0) {
        throw "Failed to list VNets in resource group '$ResourceGroup'."
    }

    $vnets = @($vnetProbe.Output | ConvertFrom-Json)
    if ($vnets.Count -eq 0) {
        return $null
    }

    $matches = @()
    foreach ($vnet in $vnets) {
        $vnetName = [string]$vnet.name
        if ([string]::IsNullOrWhiteSpace($vnetName)) {
            continue
        }

        $subnetProbe = Invoke-AzProbe -Arguments @(
            "network", "vnet", "subnet", "list",
            "--resource-group", $ResourceGroup,
            "--vnet-name", $vnetName,
            "--query", "[].{id:id,name:name,delegations:delegations}",
            "--output", "json",
            "--only-show-errors"
        ) -SuppressStderr

        if ($subnetProbe.ExitCode -ne 0) {
            continue
        }

        $subnets = @($subnetProbe.Output | ConvertFrom-Json)
        foreach ($subnet in $subnets) {
            $delegationServices = @()
            foreach ($delegation in @($subnet.delegations)) {
                if (-not [string]::IsNullOrWhiteSpace($delegation.serviceName)) {
                    $delegationServices += [string]$delegation.serviceName
                }
            }

            $hasDataMigrationDelegation = $delegationServices -contains "Microsoft.DataMigration/services"
            $hasAnyDelegation = $delegationServices.Count -gt 0
            $safeForDms = $hasDataMigrationDelegation -or (-not $hasAnyDelegation)
            if (-not $safeForDms) {
                continue
            }

            $score = 0
            if ([string]$vnet.name -like "$DmsVnetNamePrefix-*") { $score += 4 }
            if ([string]$subnet.name -like "*dms*") { $score += 3 }
            if ($hasDataMigrationDelegation) { $score += 5 }
            if (-not $hasAnyDelegation) { $score += 2 }

            $matches += @{
                subnetId = [string]$subnet.id
                region = [string]$vnet.location
                source = "discovered"
                score = $score
            }
        }
    }

    if ($matches.Count -eq 0) {
        return $null
    }

    foreach ($preferredRegion in $PreferredRegions) {
        $byRegion = @(
            $matches |
            Where-Object { $_.region.ToLower() -eq $preferredRegion.ToLower() } |
            Sort-Object -Property score -Descending
        )
        if ($byRegion.Count -gt 0) {
            return $byRegion[0]
        }
    }

    return ($matches | Sort-Object -Property score -Descending | Select-Object -First 1)
}

function Ensure-DmsDelegatedSubnet {
    param(
        [Parameter(Mandatory = $true)] [string]$ResourceGroup,
        [Parameter(Mandatory = $true)] [string]$RgToken,
        [Parameter(Mandatory = $true)] [string[]]$PreferredRegions
    )

    $targetRegion = $PreferredRegions[0].ToLower()
    $baseToken = ($RgToken.ToLower() -replace "[^a-z0-9]", "")
    if ([string]::IsNullOrWhiteSpace($baseToken)) {
        $baseToken = $RgTokenFallbackText
    }

    $vnetName = "$DmsVnetNamePrefix-$baseToken"
    if ($vnetName.Length -gt 64) {
        $vnetName = $vnetName.Substring(0, 64)
    }

    $subnetName = $DmsSubnetName
    $alternateSubnetName = $DmsAlternateSubnetName
    $vnetExists = $false
    $vnetProbe = Invoke-AzProbe -Arguments @(
        "network", "vnet", "show",
        "--resource-group", $ResourceGroup,
        "--name", $vnetName,
        "--query", "{name:name,location:location}",
        "--output", "json",
        "--only-show-errors"
    ) -SuppressStderr

    if ($vnetProbe.ExitCode -eq 0) {
        $vnet = $vnetProbe.Output | ConvertFrom-Json
        if ($vnet.location.ToLower() -eq $targetRegion) {
            $vnetExists = $true
        }
    }

    if (-not $vnetExists) {
        Write-Host "Creating VNet '$vnetName' in '$targetRegion' for DMS..." -ForegroundColor Cyan
        az network vnet create `
            --resource-group $ResourceGroup `
            --name $vnetName `
            --location $targetRegion `
            --address-prefixes $DmsVnetAddressPrefix `
            --output none `
            --only-show-errors

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create VNet '$vnetName' in '$targetRegion' for DMS."
        }
    }

    $subnetProbe = Invoke-AzProbe -Arguments @(
        "network", "vnet", "subnet", "show",
        "--resource-group", $ResourceGroup,
        "--vnet-name", $vnetName,
        "--name", $subnetName,
        "--query", "{id:id,delegations:delegations}",
        "--output", "json",
        "--only-show-errors"
    ) -SuppressStderr

    if ($subnetProbe.ExitCode -ne 0) {
        Write-Host "Creating DMS subnet '$subnetName' in VNet '$vnetName'..." -ForegroundColor Cyan
        az network vnet subnet create `
            --resource-group $ResourceGroup `
            --vnet-name $vnetName `
            --name $subnetName `
            --address-prefixes $DmsSubnetAddressPrefix `
            --output none `
            --only-show-errors

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create DMS subnet '$subnetName' in VNet '$vnetName'."
        }
    } else {
        $subnet = $subnetProbe.Output | ConvertFrom-Json
        $hasAnyDelegation = @($subnet.delegations).Count -gt 0
        if ($hasAnyDelegation) {
            Write-Host "Existing subnet '$subnetName' has delegation(s). Creating dedicated subnet '$alternateSubnetName'..." -ForegroundColor Yellow
            az network vnet subnet create `
                --resource-group $ResourceGroup `
                --vnet-name $vnetName `
                --name $alternateSubnetName `
                --address-prefixes $DmsAlternateSubnetAddressPrefix `
                --output none `
                --only-show-errors

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to create dedicated DMS subnet '$alternateSubnetName' in VNet '$vnetName'."
            }

            $subnetName = $alternateSubnetName
        }
    }

    $resolvedSubnetId = az network vnet subnet show `
        --resource-group $ResourceGroup `
        --vnet-name $vnetName `
        --name $subnetName `
        --query "id" `
        --output tsv `
        --only-show-errors

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($resolvedSubnetId)) {
        throw "Failed to resolve subnet ID for '$vnetName/$subnetName'."
    }

    return @{
        subnetId = $resolvedSubnetId.Trim()
        region = $targetRegion
        source = "created"
    }
}

function Resolve-DmsVirtualSubnetId {
    param(
        [string]$ProvidedSubnetId,
        [Parameter(Mandatory = $true)] [string]$ResourceGroup,
        [Parameter(Mandatory = $true)] [string]$RgToken,
        [Parameter(Mandatory = $true)] [string[]]$PreferredRegions
    )

    if (-not [string]::IsNullOrWhiteSpace($ProvidedSubnetId)) {
        $provided = Get-DmsSubnetMetadata -SubnetId $ProvidedSubnetId
        Write-Host "[OK] Using user-provided DMS subnet." -ForegroundColor Green
        if (-not $provided.delegated) {
            Write-Host "[WARN] Subnet is not delegated to Microsoft.DataMigration/services. Continuing because many subscriptions do not support that delegation for DMS." -ForegroundColor Yellow
        }
        return @{
            subnetId = $provided.subnetId
            region = $provided.region
            source = "provided"
        }
    }

    Write-Host "No DMS subnet provided. Searching existing suitable subnets in '$ResourceGroup'..." -ForegroundColor Cyan
    $discovered = Find-DelegatedDmsSubnetInResourceGroup -ResourceGroup $ResourceGroup -PreferredRegions $PreferredRegions
    if ($null -ne $discovered) {
        Write-Host "[OK] Reusing existing subnet for DMS: $($discovered.subnetId)" -ForegroundColor Green
        return $discovered
    }

    Write-Host "No suitable DMS subnet found. Creating one automatically..." -ForegroundColor Cyan
    return (Ensure-DmsDelegatedSubnet -ResourceGroup $ResourceGroup -RgToken $RgToken -PreferredRegions $PreferredRegions)
}

function Ensure-SqlFirewallRule {
    param(
        [Parameter(Mandatory = $true)] [string]$ResourceGroup,
        [Parameter(Mandatory = $true)] [string]$SqlServerName,
        [Parameter(Mandatory = $true)] [string]$RuleName,
        [Parameter(Mandatory = $true)] [string]$StartIpAddress,
        [Parameter(Mandatory = $true)] [string]$EndIpAddress
    )

    $null = az sql server firewall-rule create `
        --resource-group $ResourceGroup `
        --server $SqlServerName `
        --name $RuleName `
        --start-ip-address $StartIpAddress `
        --end-ip-address $EndIpAddress `
        --output none `
        --only-show-errors

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create SQL firewall rule '$RuleName' on server '$SqlServerName'."
    }
}

function Remove-SqlFirewallRuleIfExists {
    param(
        [Parameter(Mandatory = $true)] [string]$ResourceGroup,
        [Parameter(Mandatory = $true)] [string]$SqlServerName,
        [Parameter(Mandatory = $true)] [string]$RuleName
    )

    $showProbe = Invoke-AzProbe -Arguments @(
        "sql", "server", "firewall-rule", "show",
        "--resource-group", $ResourceGroup,
        "--server", $SqlServerName,
        "--name", $RuleName,
        "--output", "none",
        "--only-show-errors"
    ) -SuppressStderr

    if ($showProbe.ExitCode -ne 0) {
        return
    }

    $deleteProbe = Invoke-AzProbe -Arguments @(
        "sql", "server", "firewall-rule", "delete",
        "--resource-group", $ResourceGroup,
        "--server", $SqlServerName,
        "--name", $RuleName,
        "--output", "none",
        "--only-show-errors"
    )

    if ($deleteProbe.ExitCode -ne 0) {
        throw "Failed to remove SQL firewall rule '$RuleName' on server '$SqlServerName'."
    }
}

function Get-CurrentPublicIpAddress {
    $ipSources = @($PublicIpSources)

    foreach ($source in $ipSources) {
        try {
            $ipRaw = Invoke-RestMethod -Method Get -Uri $source -ErrorAction Stop
            $ip = ([string]$ipRaw).Trim()
            $parsed = $null
            if ([System.Net.IPAddress]::TryParse($ip, [ref]$parsed)) {
                return $ip
            }
        } catch {
            continue
        }
    }

    throw "Could not determine current public IP address for SQL firewall configuration."
}

function Ensure-SqlQueryEditorAccess {
    param(
        [Parameter(Mandatory = $true)] [string]$ResourceGroup,
        [Parameter(Mandatory = $true)] [string]$SqlServerName,
        [Parameter(Mandatory = $true)] [string]$RulePrefix
    )

    $publicIp = Get-CurrentPublicIpAddress
    $ruleName = "$RulePrefix-$($publicIp -replace '\.', '-')"
    if ($ruleName.Length -gt 128) {
        $ruleName = $ruleName.Substring(0, 128)
    }

    Write-Host "Enabling SQL Query Editor access for current public IP '$publicIp'..." -ForegroundColor Cyan
    Ensure-SqlFirewallRule `
        -ResourceGroup $ResourceGroup `
        -SqlServerName $SqlServerName `
        -RuleName $ruleName `
        -StartIpAddress $publicIp `
        -EndIpAddress $publicIp

    # Remove broad Azure-wide rule if it exists to keep least-privilege access.
    Remove-SqlFirewallRuleIfExists `
        -ResourceGroup $ResourceGroup `
        -SqlServerName $SqlServerName `
        -RuleName $AzureServicesFirewallRuleName
}

function Save-SqlCredentialsToFile {
    param(
        [Parameter(Mandatory = $true)] [string]$SqlAdminLogin,
        [Parameter(Mandatory = $true)] [string]$SqlAdminPassword,
        [string]$CredentialsDir,
        [string]$Suffix = ""
    )

    if ([string]::IsNullOrWhiteSpace($CredentialsDir)) {
        throw "CredentialsDir cannot be empty."
    }

    $credentialsDir = $CredentialsDir.Trim()
    $null = New-Item -ItemType Directory -Path $credentialsDir -Force

    $timestamp = (Get-Date).ToString($CredentialsTimestampFormat)
    $safeSuffix = ($Suffix -replace "[^a-zA-Z0-9_-]", "")
    if ([string]::IsNullOrWhiteSpace($safeSuffix)) {
        $fileName = "${CredentialsFilePrefix}_$timestamp.txt"
    } else {
        $fileName = "${CredentialsFilePrefix}_${safeSuffix}_$timestamp.txt"
    }

    $filePath = Join-Path $credentialsDir $fileName

    $lines = @(
        "CreatedOnUtc: $((Get-Date).ToUniversalTime().ToString($CredentialsCreatedOnUtcFormat))",
        "SqlAdminLogin: $SqlAdminLogin",
        "SqlAdminPassword: $SqlAdminPassword"
    )

    Set-Content -Path $filePath -Value $lines -Encoding utf8

    Write-Host "[OK] SQL credentials saved to: $filePath" -ForegroundColor Green

    return $filePath
}

function Get-InitialRegionOrLocation {
    param(
        [string[]]$Candidates,
        [string]$Fallback
    )

    if ($Candidates -and $Candidates.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($Candidates[0])) {
        return $Candidates[0]
    }

    return $Fallback
}

function Prompt-RegionChoice {
    param(
        [Parameter(Mandatory = $true)] [string]$ResourceLabel,
        [Parameter(Mandatory = $true)] [string[]]$RegionOptions
    )

    Write-Host ""
    Write-Host "$ResourceLabel deployment failed. Select a fallback region:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $RegionOptions.Count; $i++) {
        Write-Host "[$($i + 1)] $($RegionOptions[$i])"
    }
    Write-Host "[0] Stop and exit"

    $selectionRaw = Read-Host "Enter selection number"
    $selection = 0
    if (-not [int]::TryParse($selectionRaw, [ref]$selection)) {
        throw "Invalid selection input. Please run again and select a valid number."
    }

    if ($selection -eq 0) {
        throw "Deployment stopped by user."
    }

    $index = $selection - 1
    if ($index -lt 0 -or $index -ge $RegionOptions.Count) {
        throw "Selection out of range. Please run again and choose a listed number."
    }

    return $RegionOptions[$index]
}

function Invoke-ScopedDeployment {
    param(
        [Parameter(Mandatory = $true)] [string]$DeploymentName,
        [Parameter(Mandatory = $true)] [string]$ResourceGroup,
        [Parameter(Mandatory = $true)] [string]$TemplateFile,
        [Parameter(Mandatory = $true)] [string[]]$Parameters,
        [int]$PollIntervalSeconds = 20,
        [int]$TimeoutMinutes = 90
    )

    $submitArgs = @(
        "deployment", "group", "create",
        "--name", $DeploymentName,
        "--resource-group", $ResourceGroup,
        "--template-file", $TemplateFile,
        "--parameters"
    ) + $Parameters + @(
        "--no-wait",
        "--output", "none",
        "--only-show-errors"
    )

    $null = az @submitArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Deployment '$DeploymentName' submission failed."
    }

    $startTime = Get-Date
    while ($true) {
        $elapsed = (Get-Date) - $startTime
        if ($elapsed.TotalMinutes -ge $TimeoutMinutes) {
            throw "Deployment '$DeploymentName' timed out after $TimeoutMinutes minute(s)."
        }

        $stateRaw = az deployment group show `
            --name $DeploymentName `
            --resource-group $ResourceGroup `
            --query "properties.provisioningState" `
            --output tsv `
            --only-show-errors 2>$null

        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($stateRaw)) {
            Write-Host "[WAIT] Deployment '$DeploymentName' status not available yet. Elapsed: $([int]$elapsed.TotalSeconds)s" -ForegroundColor DarkCyan
            Start-Sleep -Seconds $PollIntervalSeconds
            continue
        }

        $state = $stateRaw.Trim()
        Write-Host "[WAIT] Deployment '$DeploymentName' provisioningState: $state | Elapsed: $([int]$elapsed.TotalSeconds)s" -ForegroundColor DarkCyan

        if ($state -ieq "Succeeded") {
            break
        }

        if ($state -ieq "Failed" -or $state -ieq "Canceled") {
            throw "Deployment '$DeploymentName' ended with state '$state'."
        }

        Start-Sleep -Seconds $PollIntervalSeconds
    }

    $result = az deployment group show `
        --name $DeploymentName `
        --resource-group $ResourceGroup `
        --query "properties.outputs" `
        --output json `
        --only-show-errors

    if ($LASTEXITCODE -ne 0) {
        throw "Deployment '$DeploymentName' completed but outputs could not be retrieved."
    }

    if ([string]::IsNullOrWhiteSpace($result) -or $result.Trim() -eq "null") {
        return $null
    }

    return ($result | ConvertFrom-Json)
}

function Remove-ResourceIfExists {
    param(
        [Parameter(Mandatory = $true)] [string]$ResourceGroup,
        [Parameter(Mandatory = $true)] [string]$ResourceType,
        [Parameter(Mandatory = $true)] [string]$ResourceName
    )

    az resource show `
        --resource-group $ResourceGroup `
        --resource-type $ResourceType `
        --name $ResourceName `
        --only-show-errors `
        --output none 2>$null

    if ($LASTEXITCODE -ne 0) {
        return
    }

    Write-Host "Cleaning up partially created resource: $ResourceType/$ResourceName" -ForegroundColor Yellow

    az resource delete `
        --resource-group $ResourceGroup `
        --resource-type $ResourceType `
        --name $ResourceName `
        --only-show-errors `
        --output none

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to delete partial resource: $ResourceType/$ResourceName"
    }
}

function Deploy-ResourceWithPromptedFallback {
    param(
        [Parameter(Mandatory = $true)] [string]$ResourceLabel,
        [Parameter(Mandatory = $true)] [string]$ResourceType,
        [Parameter(Mandatory = $true)] [string]$LocationParamName,
        [Parameter(Mandatory = $true)] [string]$DeployNamePrefix,
        [Parameter(Mandatory = $true)] [string[]]$RegionOptions,
        [Parameter(Mandatory = $true)] [string[]]$ToggleParams,
        [Parameter(Mandatory = $true)] [scriptblock]$NameParamsFactory,
        [Parameter(Mandatory = $true)] [scriptblock]$CleanupNameFactory,
        [Parameter(Mandatory = $true)] [string]$OutputResourceNameKey,
        [string]$InitialRegion = $Location
    )

    $regionsTried = @{}
    $currentRegion = $InitialRegion
    $attempt = 0

    while ($true) {
        if ($regionsTried.ContainsKey($currentRegion)) {
            $remaining = @($RegionOptions | Where-Object { -not $regionsTried.ContainsKey($_) })
            if ($remaining.Count -eq 0) {
                throw "$ResourceLabel failed in all suggested fallback regions."
            }
            if ($remaining.Count -eq 1) {
                $currentRegion = $remaining[0]
            } else {
                $currentRegion = Prompt-RegionChoice -ResourceLabel $ResourceLabel -RegionOptions $remaining
            }
        }

        $regionsTried[$currentRegion] = $true

        try {
            $nameParams = & $NameParamsFactory $attempt
            Write-Host "Deploying $ResourceLabel in region '$currentRegion'..." -ForegroundColor Cyan

            $outputs = Invoke-ScopedDeployment `
                -DeploymentName "$DeployNamePrefix-$effectiveSuffix-$attempt" `
                -ResourceGroup $ResourceGroupName `
                -TemplateFile $templateFile `
                -Parameters ($commonParams + $ToggleParams + $nameParams + @("$LocationParamName=$currentRegion")) `
                -PollIntervalSeconds $DeploymentPollIntervalSeconds `
                -TimeoutMinutes $DeploymentTimeoutMinutes

            $resolvedName = ""
            if ($outputs -and $outputs.$OutputResourceNameKey -and $outputs.$OutputResourceNameKey.value) {
                $resolvedName = [string]$outputs.$OutputResourceNameKey.value
            }

            if ([string]::IsNullOrWhiteSpace($resolvedName)) {
                $resolvedName = & $CleanupNameFactory $attempt
            }

            Write-Host "[OK] $ResourceLabel deployed in '$currentRegion'" -ForegroundColor Green
            return @{
                region = $currentRegion
                resourceName = $resolvedName
                attempt = $attempt
            }
        } catch {
            $cleanupName = & $CleanupNameFactory $attempt
            Remove-ResourceIfExists -ResourceGroup $ResourceGroupName -ResourceType $ResourceType -ResourceName $cleanupName
            Write-Host "[WARN] $ResourceLabel failed in '$currentRegion'." -ForegroundColor Yellow

            $remainingRegions = @($RegionOptions | Where-Object { -not $regionsTried.ContainsKey($_) })
            if ($remainingRegions.Count -eq 0) {
                throw "$ResourceLabel failed in all suggested fallback regions. Last error: $($_.Exception.Message)"
            }
            if ($remainingRegions.Count -eq 1) {
                $currentRegion = $remainingRegions[0]
            } else {
                $currentRegion = Prompt-RegionChoice -ResourceLabel $ResourceLabel -RegionOptions $remainingRegions
            }

            $attempt++
        }
    }
}

function Assert-TemplateIsSqlDmsOnly {
    param(
        [Parameter(Mandatory = $true)] [string]$TemplatePath
    )

    $content = Get-Content -LiteralPath $TemplatePath -Raw
    $matches = [System.Text.RegularExpressions.Regex]::Matches($content, "Microsoft\.[A-Za-z0-9]+/[A-Za-z0-9/]+")

    if (-not $matches -or $matches.Count -eq 0) {
        throw "No ARM resource types were found in template '$TemplatePath'."
    }

    $resourceTypes = @($matches | ForEach-Object { $_.Value } | Sort-Object -Unique)
    $disallowed = @(
        $resourceTypes | Where-Object {
            ($_ -notlike "Microsoft.Sql/*") -and ($_ -notlike "Microsoft.DataMigration/*")
        }
    )

    if ($disallowed.Count -gt 0) {
        $badList = ($disallowed -join ", ")
        throw "Template contains non-SQL/DMS resource types: $badList"
    }
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is not installed or not available in PATH."
}

$templateFile = Join-Path $PSScriptRoot $TemplateFileName
if (-not (Test-Path $templateFile)) {
    throw "Template file not found: $templateFile"
}
Assert-TemplateIsSqlDmsOnly -TemplatePath $templateFile

if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
    $existingGroupsRaw = az group list --query "[].name" --output tsv
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to list existing resource groups."
    }

    $existingGroups = @($existingGroupsRaw -split "(`r`n|`n|`r)" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    if ($existingGroups.Count -eq 1) {
        $ResourceGroupName = $existingGroups[0].Trim()
        Write-Host "Auto-selected the only available resource group: $ResourceGroupName" -ForegroundColor Green
    } elseif ($existingGroups.Count -gt 1) {
        Write-Host "Multiple resource groups found. Select one:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $existingGroups.Count; $i++) {
            Write-Host "[$($i + 1)] $($existingGroups[$i])"
        }

        $selection = Read-Host "Enter selection number"
        $parsedSelection = 0
        if (-not [int]::TryParse($selection, [ref]$parsedSelection)) {
            throw "Invalid selection. Please run again and enter a valid number."
        }

        $index = $parsedSelection - 1
        if ($index -lt 0 -or $index -ge $existingGroups.Count) {
            throw "Selection out of range. Please run again and choose a listed number."
        }

        $ResourceGroupName = $existingGroups[$index].Trim()
    } else {
        $ResourceGroupName = "$AutoResourceGroupNamePrefix-$((Get-Random -Maximum $AutoResourceGroupRandomMax).ToString('0000'))"
        Write-Host "No resource groups found. Creating: $ResourceGroupName" -ForegroundColor Yellow
    }
}

Write-Host "Using resource group: $ResourceGroupName" -ForegroundColor Cyan

$rgExistsRaw = az group exists --name $ResourceGroupName
if ($LASTEXITCODE -ne 0) {
    throw "Failed to check resource group existence."
}

$rgExists = $rgExistsRaw.Trim().ToLower()
if ($rgExists -ne "true") {
    Write-Host "Creating resource group in $Location..." -ForegroundColor Cyan
    az group create --name $ResourceGroupName --location $Location --only-show-errors --output none
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create resource group '$ResourceGroupName'."
    }
}

if ([string]::IsNullOrWhiteSpace($SqlPasswordCharset)) {
    throw "SqlPasswordCharset cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($SqlAdminLogin)) {
    throw "SqlAdminLogin cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($SqlClientFirewallRulePrefix)) {
    throw "SqlClientFirewallRulePrefix cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($AutoResourceGroupNamePrefix)) {
    throw "AutoResourceGroupNamePrefix cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DmsVnetNamePrefix)) {
    throw "DmsVnetNamePrefix cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DmsSubnetName)) {
    throw "DmsSubnetName cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DmsAlternateSubnetName)) {
    throw "DmsAlternateSubnetName cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($AzureServicesFirewallRuleName)) {
    throw "AzureServicesFirewallRuleName cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($CredentialsFilePrefix)) {
    throw "CredentialsFilePrefix cannot be empty."
}
if ($SuffixRandomMax -lt $SuffixRandomMin) {
    throw "SuffixRandomMax must be greater than or equal to SuffixRandomMin."
}
if ([string]::IsNullOrWhiteSpace($SuffixFallbackText)) {
    throw "SuffixFallbackText cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($BicepDeploymentAttemptLabel)) {
    throw "BicepDeploymentAttemptLabel cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($BicepRunDateTime)) {
    throw "BicepRunDateTime cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($RgTokenFallbackText)) {
    throw "RgTokenFallbackText cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DefaultRegionIfNone)) {
    throw "DefaultRegionIfNone cannot be empty."
}
if ($SqlAdminPasswordLength -lt 12 -or $SqlAdminPasswordLength -gt 128) {
    throw "SqlAdminPasswordLength must be between 12 and 128."
}
if ($SqlDatabaseSkuCapacity -lt 1 -or $SqlDatabaseSkuCapacity -gt 128) {
    throw "SqlDatabaseSkuCapacity must be between 1 and 128."
}
if ($DeploymentPollIntervalSeconds -lt 1 -or $DeploymentPollIntervalSeconds -gt 3600) {
    throw "DeploymentPollIntervalSeconds must be between 1 and 3600."
}
if ($DeploymentTimeoutMinutes -lt 1 -or $DeploymentTimeoutMinutes -gt 720) {
    throw "DeploymentTimeoutMinutes must be between 1 and 720."
}
if ($AutoResourceGroupRandomMax -lt 1 -or $AutoResourceGroupRandomMax -gt 1000000) {
    throw "AutoResourceGroupRandomMax must be between 1 and 1000000."
}
if ($SuffixRandomMin -lt 0 -or $SuffixRandomMin -gt 1000000) {
    throw "SuffixRandomMin must be between 0 and 1000000."
}
if ($SuffixRandomMax -lt 1 -or $SuffixRandomMax -gt 1000001) {
    throw "SuffixRandomMax must be between 1 and 1000001."
}
if ($CustomSuffixMaxBaseLength -lt 1 -or $CustomSuffixMaxBaseLength -gt 32) {
    throw "CustomSuffixMaxBaseLength must be between 1 and 32."
}
if ($RgTokenMaxLength -lt 1 -or $RgTokenMaxLength -gt 64) {
    throw "RgTokenMaxLength must be between 1 and 64."
}
if ($SqlServerNameMaxLength -lt 1 -or $SqlServerNameMaxLength -gt 128) {
    throw "SqlServerNameMaxLength must be between 1 and 128."
}
if ($SqlDatabaseNameMaxLength -lt 1 -or $SqlDatabaseNameMaxLength -gt 128) {
    throw "SqlDatabaseNameMaxLength must be between 1 and 128."
}
if ($DmsServiceNameMaxLength -lt 1 -or $DmsServiceNameMaxLength -gt 128) {
    throw "DmsServiceNameMaxLength must be between 1 and 128."
}
if ($BicepGeneratedSuffixLength -lt 1 -or $BicepGeneratedSuffixLength -gt 32) {
    throw "BicepGeneratedSuffixLength must be between 1 and 32."
}
if ($BicepRgTokenLength -lt 1 -or $BicepRgTokenLength -gt 64) {
    throw "BicepRgTokenLength must be between 1 and 64."
}
if ($PublicIpSources.Count -eq 0) {
    throw "PublicIpSources cannot be empty."
}
if ($SqlRegionCandidates.Count -eq 0) {
    throw "SqlRegionCandidates cannot be empty."
}
if ($DmsRegionCandidates.Count -eq 0) {
    throw "DmsRegionCandidates cannot be empty."
}
if ($SqlPublicNetworkAccess -ne "Enabled" -and $SqlPublicNetworkAccess -ne "Disabled") {
    throw "SqlPublicNetworkAccess must be either 'Enabled' or 'Disabled'."
}
if ([string]::IsNullOrWhiteSpace($TemplateFileName)) {
    throw "TemplateFileName cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($SqlDeploymentPrefix)) {
    throw "SqlDeploymentPrefix cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DmsDeploymentPrefix)) {
    throw "DmsDeploymentPrefix cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($SqlDeploymentLabel)) {
    throw "SqlDeploymentLabel cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DmsDeploymentLabel)) {
    throw "DmsDeploymentLabel cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($SqlResourceType)) {
    throw "SqlResourceType cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DmsResourceType)) {
    throw "DmsResourceType cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($SqlLocationParamName)) {
    throw "SqlLocationParamName cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DmsLocationParamName)) {
    throw "DmsLocationParamName cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($SqlOutputResourceNameKey)) {
    throw "SqlOutputResourceNameKey cannot be empty."
}
if ([string]::IsNullOrWhiteSpace($DmsOutputResourceNameKey)) {
    throw "DmsOutputResourceNameKey cannot be empty."
}

$effectiveSqlPublicNetworkAccess = $SqlPublicNetworkAccess
if ($effectiveSqlPublicNetworkAccess -eq "Disabled") {
    Write-Host "[WARN] SqlPublicNetworkAccess was 'Disabled'. Overriding to 'Enabled' so Query Editor can connect." -ForegroundColor Yellow
    $effectiveSqlPublicNetworkAccess = "Enabled"
}

$effectiveSuffix = New-UniqueSuffix -RequestedSuffix $Suffix
$effectiveBicepRunDateTime = Resolve-BicepRunDateTime -ConfiguredValue $BicepRunDateTime
$rgToken = Get-RgToken -RgName $ResourceGroupName
$preferredDmsRegions = Get-PreferredRegions -Candidates $DmsRegionCandidates -Fallback $Location
$resolvedDmsSubnet = Resolve-DmsVirtualSubnetId `
    -ProvidedSubnetId $DmsVirtualSubnetId `
    -ResourceGroup $ResourceGroupName `
    -RgToken $rgToken `
    -PreferredRegions $preferredDmsRegions

$DmsVirtualSubnetId = $resolvedDmsSubnet.subnetId
$resolvedDmsRegionCandidates = @($resolvedDmsSubnet.region)

$pwdChars = $SqlPasswordCharset
$sqlAdminPassword = -join ((1..$SqlAdminPasswordLength) | ForEach-Object { $pwdChars[(Get-Random -Maximum $pwdChars.Length)] })

$credentialFiles = Save-SqlCredentialsToFile `
    -SqlAdminLogin $SqlAdminLogin `
    -SqlAdminPassword $sqlAdminPassword `
    -CredentialsDir $SqlCredentialsDir `
    -Suffix $effectiveSuffix

$commonParams = @(
    "suffix=$effectiveSuffix",
    "runDateTime=$effectiveBicepRunDateTime",
    "generatedSuffixLength=$BicepGeneratedSuffixLength",
    "rgTokenLength=$BicepRgTokenLength",
    "deploymentAttemptLabel=$BicepDeploymentAttemptLabel",
    "location=$Location",
    "sqlAdminLogin=$SqlAdminLogin",
    "sqlAdminPassword=$sqlAdminPassword",
    "sqlServerVersion=$SqlServerVersion",
    "sqlPublicNetworkAccess=$effectiveSqlPublicNetworkAccess",
    "sqlDatabaseSkuName=$SqlDatabaseSkuName",
    "sqlDatabaseSkuTier=$SqlDatabaseSkuTier",
    "sqlDatabaseSkuCapacity=$SqlDatabaseSkuCapacity",
    "sqlBackupStorageRedundancy=$SqlBackupStorageRedundancy",
    "dmsVirtualSubnetId=$DmsVirtualSubnetId",
    "dmsSkuName=$DmsSkuName",
    "dmsSkuTier=$DmsSkuTier"
)
$toggleParamsSqlStep = @(
    "deploySql=$(Convert-BoolToBicepString -Value $DeploySqlForSqlStep)",
    "deployDms=$(Convert-BoolToBicepString -Value $DeployDmsForSqlStep)"
)
$toggleParamsDmsStep = @(
    "deploySql=$(Convert-BoolToBicepString -Value $DeploySqlForDmsStep)",
    "deployDms=$(Convert-BoolToBicepString -Value $DeployDmsForDmsStep)"
)

$sqlResult = Deploy-ResourceWithPromptedFallback `
    -ResourceLabel $SqlDeploymentLabel `
    -ResourceType $SqlResourceType `
    -LocationParamName $SqlLocationParamName `
    -DeployNamePrefix $SqlDeploymentPrefix `
    -RegionOptions $SqlRegionCandidates `
    -OutputResourceNameKey $SqlOutputResourceNameKey `
    -ToggleParams $toggleParamsSqlStep `
    -NameParamsFactory {
        param($attempt)
        $sqlName = Get-SqlServerName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $attempt
        $dbName = Get-SqlDatabaseName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $attempt
        $dmsName = Get-DmsServiceName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $attempt
        @("sqlServerName=$sqlName", "sqlDatabaseName=$dbName", "dmsServiceName=$dmsName")
    } `
    -CleanupNameFactory {
        param($attempt)
        Get-SqlServerName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $attempt
    } `
    -InitialRegion (Get-InitialRegionOrLocation -Candidates $SqlRegionCandidates -Fallback $Location)

$sqlServerName = $sqlResult.resourceName
$sqlDatabaseName = Get-SqlDatabaseName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $sqlResult.attempt
$sqlRegion = $sqlResult.region

Ensure-SqlQueryEditorAccess `
    -ResourceGroup $ResourceGroupName `
    -SqlServerName $sqlServerName `
    -RulePrefix $SqlClientFirewallRulePrefix

$dmsResult = Deploy-ResourceWithPromptedFallback `
    -ResourceLabel $DmsDeploymentLabel `
    -ResourceType $DmsResourceType `
    -LocationParamName $DmsLocationParamName `
    -DeployNamePrefix $DmsDeploymentPrefix `
    -RegionOptions $resolvedDmsRegionCandidates `
    -OutputResourceNameKey $DmsOutputResourceNameKey `
    -ToggleParams $toggleParamsDmsStep `
    -NameParamsFactory {
        param($attempt)
        $sqlName = Get-SqlServerName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $attempt
        $dbName = Get-SqlDatabaseName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $attempt
        $dmsName = Get-DmsServiceName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $attempt
        @("sqlServerName=$sqlName", "sqlDatabaseName=$dbName", "dmsServiceName=$dmsName")
    } `
    -CleanupNameFactory {
        param($attempt)
        Get-DmsServiceName -RgToken $rgToken -SuffixValue $effectiveSuffix -Attempt $attempt
    } `
    -InitialRegion (Get-InitialRegionOrLocation -Candidates $resolvedDmsRegionCandidates -Fallback $Location)

$dmsServiceName = $dmsResult.resourceName
$dmsRegion = $dmsResult.region

Write-Host "" 
Write-Host "Deployment complete:" -ForegroundColor Green
Write-Host "  Resource Group:          $ResourceGroupName"
Write-Host "  SQL Server:              $sqlServerName ($sqlRegion)"
Write-Host "  SQL Database:            $sqlDatabaseName"
Write-Host "  SQL Admin Login:         $SqlAdminLogin"
Write-Host "  SQL Admin Password:      $sqlAdminPassword"
Write-Host "  DMS Service:             $dmsServiceName ($dmsRegion)"
Write-Host "  DMS Subnet Id:           $DmsVirtualSubnetId"
Write-Host "  DMS Subnet Source:       $($resolvedDmsSubnet.source)"
Write-Host "  SQL Credential File:     $credentialFiles"
