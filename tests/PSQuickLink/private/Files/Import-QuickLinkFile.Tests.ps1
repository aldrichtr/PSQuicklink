BeforeAll {
    # This method requires `tests/` to be structured the same as `source/`
    $sourceFile = $PSCommandPath -replace '\.Tests\.ps1', '.ps1'
    $sourceFile = $sourceFile -replace 'tests' , 'source'
    if (Test-Path $sourceFile) {
        . $sourceFile
    } else {
        throw "Could not find $sourceFile from $PSCommandPath"
    }
}

Describe 'Testing the private function Import-QuickLinkFile' -Tag @('unit', 'Import-QuickLinkFile') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Import-QuickLinkFile'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When a file is imported' {
        BeforeAll {
            function Get-QuickLinkFilePath ($Path) { }


            $configFile = (Join-Path $TestDrive '.quicklinks.psd1')
            @'
@{
    config     = @{
        shortcode = @{
            start = '['
            end   = ':]'
        }
    }

    links      = @(
        @{
            name = 'psgallery'
            uri  = 'https://www.powershellgallery.com'
            tags = @(
                'pwsh'
            )
        }
    )

    shortcodes = @(
        @{
            id    = 'gh'
            name  = 'GitHub'
            uri   = 'https://github.com/'
            type = 'web'
        }
        @{
            id    = 'gl'
            name  = 'Google'
            uri   = 'https://google.com/'
            type = 'web'
        }
    )
}
'@ | Set-Content $configFile

            Mock 'Get-QuickLinkFilePath' {
                return $configFile
            }

            $settings = Import-QuickLinkFile -Path $configFile
        }

        Context 'When the configuration contains shortcodes' -ForEach $settings.shortcodes {
            BeforeAll {
                $shortCode = $_
            }
            It 'Should have four keys' {
                $shortCode.Keys.count | Should -Be 4
            }

            It 'Should have an id' {
                $shortCode.id | Should -Not -BeNullOrEmpty
            }

            It 'Should have a name' {
                $shortCode.name | Should -Not -BeNullOrEmpty
            }
            It 'Should have an uri' {
                $shortCode.uri | Should -Not -BeNullOrEmpty
            }

            It 'Should have a type' {
                $shortCode.type | Should -Not -BeNullOrEmpty
            }
        }

        Context 'When the configuration contains settings' {
            BeforeAll {
                $config = $settings.config
            }

            It 'Should have shortcode config' {
                $config.Keys | Should -Contain 'shortcode'
            }

            It 'Should have a shortcode start of [' {
                $config.shortcode.start | Should -BeExactly '['
            }

            It 'Should have a shortcode end of :]' {
                $config.shortcode.end | Should -BeExactly ':]'
            }
        }

        Context 'When the configuration contains links' -ForEach $settings.links {
            BeforeAll {
                $links = $_
            }

            It 'Should have three keys' {
                $link.Keys.count | Should -Be 3
            }

            It 'Should have a name' {
                $link.name | Should -Not -BeNullOrEmpty
            }
            It 'Should have an uri' {
                $link.uri | Should -Not -BeNullOrEmpty
            }

            It 'Should have a tags' {
                $link.tags | Should -Not -BeNullOrEmpty
            }

            It 'Should have one tag' {
                $link.tags.Count | Should -Be 1
            }
        }

    }
}
