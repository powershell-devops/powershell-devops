#Requires -Version 7
#Requires -Module @{ModuleName='Pester';ModuleVersion='5.2.0'}

Describe 'powershell-devops.psm1' {
    BeforeAll {
        Import-Module $PSCommandPath.Replace('.tests.ps1','.psm1')
        $env:TF_BUILD=$null
        $env:GITHUB_ACTIONS=$null
    }

    BeforeEach {
        $env:ENV_VARIABLE=$null
    }

    It 'when TF_BUILD is not defined Test-AdoPipeline should return false' {
        Test-AdoPipeline | Should -Be $false
    }

    It 'when GITHUB_ACTIONS is not defined Test-GitHubWorkflow should return false' {
        Test-GitHubWorkflow | Should -Be $false
    }

    It 'when Set-EnvironmentVariable then the environment variable should be set' {
        Set-EnvironmentVariable ENV_VARIABLE VALUE
        $env:ENV_VARIABLE | Should -Be VALUE
    }

    It 'when an environment variable is defined and Get-EnvironmentVariable then the value should be returned' {
        $env:ENV_VARIABLE = 'VALUE'
        Get-EnvironmentVariable ENV_VARIABLE | Should -Be VALUE
    }

    It 'when an environment variable not defined and Get-EnvironmentVariable with Require then should throw' {
        { Get-EnvironmentVariable ENV_VARIABLE -Require } | Should -Throw
    }

    Context 'Azure DevOps' {
        BeforeEach {
            $env:TF_BUILD=1
        }

        AfterEach {
            $env:TF_BUILD=$null
        }

        It 'when TF_BUILD is defined Test-AdoPipeline should return true' {
            Test-AdoPipeline | Should -Be $true
        }

        It 'when Set-EnvironmentVariable then the host should write command ##vso[task.setvariable]' {
            Set-EnvironmentVariable ENV_VARIABLE VALUE *>&1 | Should -BeLike '##vso`[task.setvariable *'
        }

        It 'when Set-EnvironmentVariable with Secret then the host should write command ##vso[task.setvariable issecret=true`]' {
            Set-EnvironmentVariable ENV_VARIABLE VALUE -Secret *>&1 | Should -BeLike '##vso`[task.setvariable *;issecret=true;*'
        }

        It 'when Set-EnvironmentVariable with Output then the host should write command ##vso[task.setvariable isoutput=true`]' {
            Set-EnvironmentVariable ENV_VARIABLE VALUE -Output *>&1 | Should -BeLike '##vso`[task.setvariable *;isoutput=true;*'
        }

        It 'when Enter-Group then the host should write command ##[group]' {
            Enter-Group GROUP *>&1 | Should -BeLike '##`[group`]*'
        }

        It 'when Exit-Group then the host should write command ##[endgroup]' {
            Exit-Group *>&1 | Should -BeLike '##`[endgroup`]*'
        }

        It 'when Add-Path then the host should write command ##vso[task.prependpath]' {
            Add-Path /path *>&1 | Should -BeLike '##vso`[task.prependpath`]*'
        }
    }

    Context 'GitHub' {
        BeforeEach {
            $env:GITHUB_ACTIONS=1
            $env:GITHUB_ENV = [System.IO.Path]::GetTempFileName()
            $env:GITHUB_PATH = [System.IO.Path]::GetTempFileName()
        }

        AfterEach {
            $env:GITHUB_ACTIONS=$null
            Remove-Item -Path $env:GITHUB_ENV -Force
            Remove-Item -Path $env:GITHUB_PATH -Force
        }

        It 'when GITHUB_ACTIONS is defined Test-GitHubWorkflow should return true' {
            Test-GitHubWorkflow | Should -Be $true
        }

        It 'when Set-EnvironmentVariable then the host should put ENV_VARIABLE in GITHUB_ENV' {
            Set-EnvironmentVariable ENV_VARIABLE VALUE
            Get-Content -Path $env:GITHUB_ENV | Should -BeLike 'ENV_VARIABLE=*'
        }

        It 'when Set-EnvironmentVariable with Secret then the host should write command ::add-mask::' {
            Set-EnvironmentVariable ENV_VARIABLE VALUE -Secret *>&1 | Should -BeLike '::add-mask::*'
        }

        It 'when Set-EnvironmentVariable with Output then the host should write command ::set-output name=' {
            Set-EnvironmentVariable ENV_VARIABLE VALUE -Output *>&1 | Should -BeLike '::set-output name=*'
        }

        It 'when Enter-Group then the host should write command ::group::' {
            Enter-Group GROUP *>&1 | Should -BeLike '::group::*'
        }

        It 'when Exit-Group then the host should write command ::endgroup::' {
            Exit-Group *>&1 | Should -BeLike '::endgroup::*'
        }

        It 'when Add-Path then the host should put PATH in GITHUB_PATH' {
            Add-Path /path
            Get-Content -Path $env:GITHUB_PATH | Should -Be '/path'
        }
    }
}