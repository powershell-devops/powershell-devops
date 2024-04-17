@{
    ModuleVersion = '1.0.1'
    RootModule = 'powershell-devops.psm1'
    GUID = 'c1bdd96a-5c69-43f7-8155-9cd5f5a6019d'
    Author = 'https://github.com/smokedlinq'
    Description = 'PowerShell module for dealing with commands in Azure DevOps Pipelines and GitHub Workflows.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Test-AdoPipeline',
        'Test-GitHubWorkflow',
        'Set-EnvironmentVariable',
        'Get-EnvironmentVariable',
        'Enter-Group',
        'Exit-Group',
        'Add-Path'
    )
    AliasesToExport = @(
        'set-env',
        'get-env'
    )

    PrivateData = @{
        PSData = @{
            Tags = @('Azure', 'DevOps', 'GitHub', 'Pipelines', 'Actions', 'Workflows')
            ProjectUri = 'https://github.com/smokedlinq/powershell-devops'
        }
    }
}
