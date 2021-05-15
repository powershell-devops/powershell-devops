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

function Write-Warning {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName='Default')]
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName='AsJson')]
        $Message,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $AsJson = $false,

        [Parameter(ParameterSetName='AsJson')]
        [ValidateRange(1, 100)]
        [int] $Depth = 4,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $AsArray = $false,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $EnumAsStrings = $false,

        [Parameter(ParameterSetName='AsJson')]
        [Newtonsoft.Json.StringEscapeHandling] $EscapeHandling = [Newtonsoft.Json.StringEscapeHandling]::Default
    )

    process {
        if ($WarningPreference -ne 'SilentlyContinue') {
            if ($AsJson) {
                $Message = $Message | ConvertTo-Json -Depth $Depth -Compress -AsArray:$AsArray -EnumsAsStrings:$EnumAsStrings -EscapeHandling $EscapeHandling
            }

            if (Test-AdoPipeline) {
                Write-Host "##[warning]$Message"
            } elseif (Test-GitHubWorkflow) {
                Write-Host "::warning::$Message"
            } else {
                Microsoft.PowerShell.Utility\Write-Warning -Message $Message
            }
        }
    }
}

function Write-Verbose {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName='Default')]
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName='AsJson')]
        $Message,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $AsJson = $false,

        [Parameter(ParameterSetName='AsJson')]
        [ValidateRange(1, 100)]
        [int] $Depth = 4,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $AsArray = $false,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $EnumAsStrings = $false,

        [Parameter(ParameterSetName='AsJson')]
        [Newtonsoft.Json.StringEscapeHandling] $EscapeHandling = [Newtonsoft.Json.StringEscapeHandling]::Default
    )

    process {
        if ($VerbosePreference -ne 'SilentlyContinue') {
            if ($AsJson) {
                $Message = $Message | ConvertTo-Json -Depth $Depth -Compress -AsArray:$AsArray -EnumsAsStrings:$EnumAsStrings -EscapeHandling $EscapeHandling
            }

            if (Test-AdoPipeline) {
                Write-Host "##[debug]$Message"
            } elseif (Test-GitHubWorkflow) {
                Write-Host "::debug::$Message"
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose -Message $Message
            }
        }
    }
}

function Write-Debug {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName='Default')]
        [Parameter(Mandatory, Position=0, ValueFromPipeline, ParameterSetName='AsJson')]
        $Message,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $AsJson = $false,

        [Parameter(ParameterSetName='AsJson')]
        [ValidateRange(1, 100)]
        [int] $Depth = 4,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $AsArray = $false,

        [Parameter(ParameterSetName='AsJson')]
        [switch] $EnumAsStrings = $false,

        [Parameter(ParameterSetName='AsJson')]
        [Newtonsoft.Json.StringEscapeHandling] $EscapeHandling = [Newtonsoft.Json.StringEscapeHandling]::Default
    )

    process {
        if ($DebugPreference -ne 'SilentlyContinue') {
            if ($AsJson) {
                $Message = $Message | ConvertTo-Json -Depth $Depth -Compress -AsArray:$AsArray -EnumsAsStrings:$EnumAsStrings -EscapeHandling $EscapeHandling
            }

            if (Test-AdoPipeline) {
                Write-Host "##[debug]$Message"
            } elseif (Test-GitHubWorkflow) {
                Write-Host "::debug::$Message"
            } else {
                Microsoft.PowerShell.Utility\Write-Debug -Message $Message
            }
        }
    }
}