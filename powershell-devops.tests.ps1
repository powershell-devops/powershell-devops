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

    Context 'Test-AdoPipeline' {
        It 'when TF_BUILD is not defined should return false' {
            Test-AdoPipeline | Should -Be $false
        }
    }

    Context 'Test-GitHubWorkflow' {
        It 'when GITHUB_ACTIONS is not defined should return false' {
            Test-GitHubWorkflow | Should -Be $false
        }
    }

    Context 'Set-EnvironmentVariable' {
        It 'when Set-EnvironmentVariable then the environment variable should be set' {
            Set-EnvironmentVariable ENV_VARIABLE VALUE
            $env:ENV_VARIABLE | Should -Be VALUE
        }
    }

    Context 'Get-EnvironmentVariable' {
        It 'when an environment variable is defined then the value should be returned' {
            $env:ENV_VARIABLE = 'VALUE'
            Get-EnvironmentVariable ENV_VARIABLE | Should -Be VALUE
        }

        It 'when an environment variable not defined and -Require is true then should throw' {
            { Get-EnvironmentVariable ENV_VARIABLE -Require } | Should -Throw
        }
    }

    Context 'Azure DevOps' {
        BeforeEach {
            $env:TF_BUILD=1
        }

        AfterEach {
            $env:TF_BUILD=$null
        }

        Context 'Test-AdoPipeline' {
            It 'when TF_BUILD is defined should return true' {
                Test-AdoPipeline | Should -Be $true
            }
        }

        Context 'Set-EnvironmentVariable' {
            It 'should write command ##vso[task.setvariable]' {
                Set-EnvironmentVariable ENV_VARIABLE VALUE *>&1 | Should -BeLike '##vso`[task.setvariable *'
            }

            It 'with -Secret then should write command ##vso[task.setvariable issecret=true`]' {
                Set-EnvironmentVariable ENV_VARIABLE VALUE -Secret *>&1 | Should -BeLike '##vso`[task.setvariable *;issecret=true;*'
            }

            It 'with -Output then should write command ##vso[task.setvariable isoutput=true`]' {
                Set-EnvironmentVariable ENV_VARIABLE VALUE -Output *>&1 | Should -BeLike '##vso`[task.setvariable *;isoutput=true;*'
            }
        }

        Context 'Enter-Group' {
            It 'should write command ##[group]' {
                Enter-Group GROUP *>&1 | Should -BeLike '##`[group`]*'
            }
        }

        Context 'Exit-Group' {
            It 'should write command ##[endgroup]' {
                Exit-Group *>&1 | Should -BeLike '##`[endgroup`]*'
            }
        }

        Context 'Add-Path' {
            It 'should write command ##vso[task.prependpath]' {
                Add-Path /path *>&1 | Should -BeLike '##vso`[task.prependpath`]*'
            }
        }
    }

    Context 'GitHub' {
        BeforeEach {
            $env:GITHUB_ACTIONS=1
            $env:GITHUB_ENV = [System.IO.Path]::GetTempFileName()
            $env:GITHUB_OUTPUT = [System.IO.Path]::GetTempFileName()
            $env:GITHUB_PATH = [System.IO.Path]::GetTempFileName()
        }

        AfterEach {
            $env:GITHUB_ACTIONS=$null
            Remove-Item -Path $env:GITHUB_ENV -Force
            Remove-Item -Path $env:GITHUB_OUTPUT -Force
            Remove-Item -Path $env:GITHUB_PATH -Force
        }

        Context 'Test-GitHubWorkflow' {
            It 'when GITHUB_ACTIONS is defined should return true' {
                Test-GitHubWorkflow | Should -Be $true
            }
        }

        Context 'Set-EnvironmentVariable' {
            It 'should put name=value in GITHUB_ENV' {
                Set-EnvironmentVariable ENV_VARIABLE VALUE
                Get-Content -Path $env:GITHUB_ENV | Should -BeLike 'ENV_VARIABLE=*'
            }

            It 'with -Secret then should write command ::add-mask::' {
                Set-EnvironmentVariable ENV_VARIABLE VALUE -Secret *>&1 | Should -BeLike '::add-mask::*'
            }

            It 'with -Output then should put name=value in GITHUB_OUTPUT' {
                Set-EnvironmentVariable ENV_VARIABLE VALUE -Output
                Get-Content -Path $env:GITHUB_OUTPUT | Should -BeLike 'ENV_VARIABLE=*'
            }
        }

        Context 'Enter-Group' {
            It 'should write command ::group::' {
                Enter-Group GROUP *>&1 | Should -BeLike '::group::*'
            }
        }

        Context 'Exit-Group' {
            It 'should write command ::endgroup::' {
                Exit-Group *>&1 | Should -BeLike '::endgroup::*'
            }
        }

        Context 'Add-Path' {
            It 'should put value in GITHUB_PATH' {
                Add-Path /path
                Get-Content -Path $env:GITHUB_PATH | Should -Be '/path'
            }
        }
    }
}