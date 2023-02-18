

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

Describe 'Testing private public Get-QuickLink' -Tags @('unit', 'QuickLink', 'Get' ) {
    Context 'The Get-QuickLink command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Get-QuickLink'
        }

        It 'It should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }

        It "It Should have a 'Name' parameter" {
            $command.Parameters['Name'].Count | Should -Be 1
        }
        It "It Should have a 'Tag' parameter" {
            $command.Parameters['Tag'].Count | Should -Be 1
        }
    }

    Context 'When links are present in the settings' {
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
                    shortcodes = @{}
                    links = @(
                        @{
                            name = 'psgallery'
                            uri  = 'https://www.powershellgallery.com'
                            tags = @(
                                'powershell'
                            )
                        }
                        @{
                            name = 'vscode'
                            uri  = 'https://code.visualstudio.com/Docs'
                            tags = @(
                                'editor'
                                'docs'
                            )
                        }
                    )
                }
            }
            $links = Get-QuickLink
        }

        It 'It Should return two quicklinks' {
            $links.count | Should -Be 2
        }
    }
}
