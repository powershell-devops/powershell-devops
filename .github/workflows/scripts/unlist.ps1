#Requires -Version 7
#Requires -Module powershell-devops

[CmdletBinding()]
param(
    [string] $TAG_NAME = $(Get-EnvironmentVariable TAG_NAME -Require),
    [string] $POWERSHELLGALLERY_KEY = $(Get-EnvironmentVariable POWERSHELLGALLERY_KEY -Require)
)

$ErrorActionPreference = 'Stop'

$Version = $TAG_NAME -replace '^v'

Write-Host "Unlisting version: $Version"

Invoke-RestMethod https://www.powershellgallery.com/api/v2/package/powershell-devops/$Version `
  -Method DELETE `
  -Headers @{'X-NuGet-ApiKey' = $POWERSHELLGALLERY_KEY}