#Requires -Version 7
#Requires -Module powershell-devops

[CmdletBinding()]
param(
    [string] $RELEASE_ID = $(Get-EnvironmentVariable RELEASE_ID -Require),
    [string] $TAG_NAME = $(Get-EnvironmentVariable TAG_NAME -Require),
    [string] $GITHUB_REPOSITORY = $(Get-EnvironmentVariable GITHUB_REPOSITORY -Require),
    [string] $POWERSHELLGALLERY_KEY = $(Get-EnvironmentVariable POWERSHELLGALLERY_KEY -Require)
)

$ErrorActionPreference = 'Stop'

$Version = $TAG_NAME -replace '^v'

if (Find-Module powershell-devops -RequiredVersion $Version -ErrorAction SilentlyContinue) {
    Write-Host "Relisting version: $Version"

    Invoke-RestMethod https://www.powershellgallery.com/api/v2/package/powershell-devops/$Version `
        -Method POST `
        -Headers @{'X-NuGet-ApiKey' = $POWERSHELLGALLERY_KEY}
} else {
    Write-Host "Publishing version: $Version"

    Publish-Module -Path .\ -NuGetApiKey $POWERSHELLGALLERY_KEY
}

$LatestRelease = Invoke-RestMethod https://api.github.com/repos/$GITHUB_REPOSITORY/releases/latest

if ($LatestRelease.id -eq $RELEASE_ID) {
    Set-EnvironmentVariable MAJOR_TAG_NAME "v$($Version -split '\.' | Select-Object -First 1)"
}