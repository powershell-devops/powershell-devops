New-Alias -Name set-env -Value Set-EnvironmentVariable

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
    }

    if (Test-GitHubWorkflow) {
        if ($Secret) {
            Write-Host "::add-mask::$Value"
        }
        if ($Output) { 
            Write-Host "::set-output name=$Name::$Value"
        } else {
            "$Name=$Value" | Out-File -FilePath $env:GITHUB_ENV -Append
        }
    }

    Set-Item -Path env:$Name -Value $Value -Force
}
