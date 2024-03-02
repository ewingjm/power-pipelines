<#
.SYNOPSIS
    Removes environments older than a given number of days
.DESCRIPTION
    This script should be used to delete stale environments e.g. as a fallback for cleaning up ephemeral environments when the primary process responsible for their deletion doesn't work as intended.
.NOTES
    Use this script with caution - ensure filters are suitably restrictive. Use of wildcards (*) is supported.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $TenantId,
    [Parameter(Mandatory)]
    [string]
    $ClientId,
    [Parameter(Mandatory)]
    [string]
    $ClientSecret,
    [Parameter(Mandatory)]
    [int]
    $OlderThanInDays,
    [Parameter(Mandatory)]
    [string]
    $SearchString,
    [Parameter()]
    [string]
    $CreatedBy
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module Microsoft.PowerApps.Administration.PowerShell -ListAvailable)) {
    Install-Module Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser -Force
}

Write-Host "Authenticating as $ClientId.`n"
Add-PowerAppsAccount -TenantID $TenantId -ApplicationId $ClientId -ClientSecret $ClientSecret

Write-Host "Finding environments matching $SearchString."
$environmentCriteria = @{
    Filter = $SearchString
}
if ($CreatedBy) {
    Write-Host "Excluding environments not created by $CreatedBy."
    $environmentCriteria.CreatedBy = $CreatedBy
}
[array]$environments = Get-AdminPowerAppEnvironment @environmentCriteria | 
Select-Object DisplayName, EnvironmentName, @{ 
    name       = 'CreatedOn'
    expression = { [DateTime]::Parse($_.CreatedTime) } 
}

Write-Host "Found $($environments.Count) environments matching the filter."
if ($environments.Count -gt 0) {
    $environments | Format-Table
}
else {
    return
}

Write-Host "Filtering out environments created within the last $OlderThanInDays days."
$environments = $environments | 
Where-Object { $_.CreatedOn -lt [datetime]::Now.AddDays(-$OlderThanInDays) }

Write-Host "Found $($environments.Count) environments older than $OlderThanInDays days."
if ($environments.Count -gt 0) {
    $environments | Format-Table
    Write-Host "##vso[build.addbuildtag]StaleEnvironmentsFound"
}
else {
    return
}

$environments | ForEach-Object { 
    Write-Host "Deleting $($_.DisplayName) environment."
    Remove-AdminPowerAppEnvironment -EnvironmentName $_.EnvironmentName 
}