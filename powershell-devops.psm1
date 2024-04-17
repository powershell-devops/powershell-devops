New-Alias -Name set-env -Value Set-EnvironmentVariable
New-Alias -Name get-env -Value Get-EnvironmentVariable

function Test-AdoPipeline {
    [OutputType([bool])]
    [CmdletBinding()]
    param()
    return ![string]::IsNullOrEmpty($env:TF_BUILD)
}

function Test-GitHubWorkflow {
    [OutputType([bool])]
    [CmdletBinding()]
    param()
    return ![string]::IsNullOrEmpty($env:GITHUB_ACTIONS)
}

function Set-EnvironmentVariable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, Position=1, ValueFromPipeline)]
        $Value,

        [switch] $Secret = $false,
        [switch] $Output = $false
    )

    if (Test-AdoPipeline) {
        Write-Host "##vso[task.setvariable variable=$Name;$($Secret ? 'issecret=true;' : '')$($Output ? 'isoutput=true;' : '')]$Value"
    } elseif (Test-GitHubWorkflow) {
        if ($Secret) {
            Write-Host "::add-mask::$Value"
        }
        if ($Output) { 
            "$Name=$Value" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
        }
        "$Name=$Value" | Out-File -FilePath $env:GITHUB_ENV -Append
    }

    Set-Item -Path env:$Name -Value $Value -Force
}

function Get-EnvironmentVariable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [switch] $Require = $false
    )

    if (Test-Path -Path env:$Name -PathType Leaf) {
        (Get-Item -Path env:$Name).Value
    } elseif ($Require) {
        throw "The environment variable '$Name' is missing or undefined."
    }
}

function Enter-Group {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Name
    )

    if (Test-AdoPipeline) {
        Write-Host "##[group]$Name"
    } elseif (Test-GitHubWorkflow) {
        Write-Host "::group::$Name"
    }
}

function Exit-Group {
    [CmdletBinding()]
    param ()
    
    if (Test-AdoPipeline) {
        Write-Host '##[endgroup]'
    } elseif (Test-GitHubWorkflow) {
        Write-Host '::endgroup::'
    }   
}

function Add-Path {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Path
    )
    
    if (Test-AdoPipeline) {
        Write-Host "##vso[task.prependpath]$Path"
    } elseif (Test-GitHubWorkflow) {
        $Path >> $env:GITHUB_PATH
    }

    $env:PATH = "$Path;$env:PATH"
}
