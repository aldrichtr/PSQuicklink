
BeforeAll {
    # Convert the test file's name into the source file's name and then
    # dot-source the source file
    # This method requires `tests/` to be structured the same as `source/`

    $sourceFile = $PSCommandPath -replace '\.Tests\.ps1', '.ps1'
    $sourceFile = $sourceFile -replace 'tests' , 'source'
    if (Test-Path $sourceFile) {
        . $sourceFile
    } else {
        throw "Could not find $sourceFile from $PSCommandPath"
    }
}

Describe "Testing private public Get-LinkShortCode" -Tags @('unit', 'LinkShortCode', 'Get' ) {
    Context 'When the Get-LinkShortCode command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Get-LinkShortCode'
        }

        It 'It should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }

        It "It Should have a 'Id' parameter" {
            $command.Parameters['Id'].Count | Should -Be 1
        }
        It "It Should have a 'Name' parameter" {
            $command.Parameters['Name'].Count | Should -Be 1
        }
        It "It Should have a 'Type' parameter" {
            $command.Parameters['Type'].Count | Should -Be 1
        }
    }

    Context 'When shortcodes are present in the settings' {
        BeforeAll {
            #! Pester needs a function to exist in order to Mock it.  Since we are not loading
            #! the module, this function does not exist yet.
            function Import-QuickLinkFile {}

            Mock -CommandName Import-QuickLinkFile -MockWith {
                return @{
                    config     = @{
                        shortcode = @{
                            start = '['
                            end   = ':]'
                        }
                    }
                    shortcodes = @(
                        @{
                            id   = 'gh'
                            name = 'GitHub'
                            uri  = 'https://github.com/'
                            type = 'web'
                        }
                        @{
                            id   = 'gl'
                            name = 'Google'
                            uri  = 'https://google.com/'
                            type = 'web'
                        }
                    )
                }
            }

            $shortCodes = Get-LinkShortCode
        }

        It 'It should return two shortcode objects' {
            $shortCodes.count | Should -Be 2
        }

        Context "When the -Id '<id>' parameter is used" -ForEach @(
            @{
                id   = 'gh'
                name = 'GitHub'
                uri  = 'https://github.com/'
                type = 'web'
            }
            @{
                id   = 'gl'
                name = 'Google'
                uri  = 'https://google.com/'
                type = 'web'
            }

        ) {
            BeforeAll {
                $shortCode = Get-LinkShortCode -Id $id
            }

            It "It should return an object with the id '$id'" {
                $shortCode.id | Should -Be $id
            }

            It "It should return an object with the name '$name'" {
                $shortCode.name | Should -Be $name
            }

            It "It should return an object with the uri '$uri'" {
                $shortCode.uri | Should -Be $uri
            }

            It "It should return an object with the type '$type'" {
                $shortCode.type | Should -Be $type
            }
        }

        Context "When the -Name '<name>' parameter is used" -ForEach @(
            @{
                id   = 'gh'
                name = 'GitHub'
                uri  = 'https://github.com/'
                type = 'web'
            }
            @{
                id   = 'gl'
                name = 'Google'
                uri  = 'https://google.com/'
                type = 'web'
            }

        ) {
            BeforeAll {
                $shortCode = Get-LinkShortCode -Id $id
            }

            It "It should return an object with the id '$id'" {
                $shortCode.id | Should -Be $id
            }

            It "It should return an object with the name '$name'" {
                $shortCode.name | Should -Be $name
            }

            It "It should return an object with the uri '$uri'" {
                $shortCode.uri | Should -Be $uri
            }

            It "It should return an object with the type '$type'" {
                $shortCode.type | Should -Be $type
            }
        }

        Context "When the -Type '<type>' parameter is used" -ForEach @(
            @{ type = 'web'}
        ) {
            BeforeAll {
                $shortCodes = Get-LinkShortCode -Type $type
            }

            It "It should return two shortcodes" {
                $shortCodes.Count | Should -Be 2
            }
        }

    }
}
