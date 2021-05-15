# powershell-devops

PowerShell module for dealing with commands in Azure DevOps Pipelines and GitHub Workflows.

## Set-EnvironmentVariable

Sets the environment variable for the current process and optionally marks it as a secret.

```powershell
set-env MY_VALUE 'Hello World!'
```

*Note: `set-env` is an alias for `Set-EnvironmentVariable`.*

## Get-EnvironmentVariable

Gets the environment variable for the current process and optionally throws an error if it is not defined.

```powershell
get-env MY_ENV_VALUE -Require
```

*Note: `get-env` is an alias for `Get-EnvironmentVariable`.*

## Add-Path

Prepends the value to the PATH environment.

```powershell
Add-Path $PSScriptRoot
```

## Enter-Group / Exit-Group

Creates an expandable group in the log. Anything you print to the log between the `Enter-Group` and `Exit-Group` commands is nested inside an expandable entry in the log.

```powershell
Enter-Group 'My group'
try {
    # .. some other commands ...
} finally {
    Exit-Group
}
```

## Enhanced behavior functions

These functions enhance the behavior of existing cmdlets to operate more concisely in the DevOps environment.

### Write-Warning

Writes the message as a warning and optionally converts the input to JSON.

```powershell
@{
    Target = 'Target'
    Message = 'Message'
} | Write-Warning -AsJson

Write-Warning "Warning"
```

*Note: JSON objects are always compressed to fit on a single line.*

### Write-Verbose

Writes the message as verbose and optionally converts the input to JSON.

```powershell
@{
    Target = 'Target'
    Message = 'Message'
} | Write-Verbose -AsJson

Write-Verbose "Verbose"
```

*Note: JSON objects are always compressed to fit on a single line.*

### Write-Debug

Writes the message as debug and optionally converts the input to JSON.

```powershell
@{
    Target = 'Target'
    Message = 'Message'
} | Write-Debug -AsJson

Write-Debug "Debug"
```

*Note: JSON objects are always compressed to fit on a single line.*

## Utility functions

These functions are helper functions that are used by the module but could also be useful within your script.

### Test-AdoPipeline

Returns true if running in an Azure DevOps Pipeline, determined by the environment variable `TF_BUILD` having a value.

```powershell
Test-AdoPipeline
```

### Test-GitHubWorkflow

Returns true if running in a GitHub Workflow, determined by the environment variable `GITHUB_ACTIONS` having a value.

```powershell
Test-GitHubWorkflow
```
