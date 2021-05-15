#Requires -Version 7
#Requires -Module powershell-devops

[CmdletBinding()]
param(
    [string] $TAG_NAME = $(Get-EnvironmentVariable TAG_NAME -Require)
)

$ErrorActionPreference = 'Stop'

$Version = $TAG_NAME -replace '^v'
$Manifest = Test-ModuleManifest .\powershell-devops.psd1

if ($Version -ne $Manifest.Version) {
    throw "The module version '$($Manifest.Version)' does not match the release version '$Version'."
}