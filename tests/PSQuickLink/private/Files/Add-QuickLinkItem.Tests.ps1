

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

Describe 'Testing private function Add-QuickLinkItem' -Tags @('unit', 'QuickLinkItem', 'Add' ) {
    Context 'The Add-QuickLinkItem command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Add-QuickLinkItem'
        }

        It 'It should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }

        It "It Should have a 'Section' parameter" {
            $command.Parameters['Section'].Count | Should -Be 1
        }
        It "It Should have a 'Table' parameter" {
            $command.Parameters['Table'].Count | Should -Be 1
        }
    }
    Context 'When adding links to the settings file' -ForEach @(
        @{
            Section = 'links'
            Table = @{
                name = 'update'
                uri = 'https://updated.uri'
                tags = @(
                    'tag1'
                )
            }
        }
    ) {
        BeforeAll {
            $testSettingsFile = (Join-Path $TestDrive 'setquicklinkitem.psd1')

            function Get-QuickLinkFilePath {}

            Mock -CommandName Get-QuickLinkFilePath -MockWith { return $testSettingsFile }

            $settingsContent = @'
@{
config     = @{
    shortcode = @{ start = '['; end = ':]' }
}
shortcodes = @(
    @{
        # with a comment in GitHub
        id   = 'gh'
        name = 'GitHub'
        uri  = 'https://github.com/'
        type = 'web'
    }
)
links      = @(
    @{
        # with a comment in ql-docs
        name = 'ql-docs'
        uri  = '[gh:]aldrichtr/PSQuickLinks/blob/main/docs'
        tags = @(
            'docs'
            )
    }
)
}
'@
            $settingsContent | Set-Content $testSettingsFile

            #! $_ is the hashtable of values in the ForEach which we splat to the function
            Add-QuickLinkItem @_

            $newSettingsTable = Import-Psd $testSettingsFile
        }

        It 'It should have two links listed' {
            $newSettingsTable.links.Count | Should -Be 2
        }

        It 'It should have a link with the name update' {
            $newSettingsTable.links | Where-Object name -like 'update' | Should -Not -BeNullOrEmpty
        }

        It 'It should have a link with the name ql-docs' {
            $newSettingsTable.links | Where-Object name -like 'ql-docs' | Should -Not -BeNullOrEmpty
        }

        It 'It should retain the comment in links' {
            $testSettingsFile | Should -FileContentMatch '# with a comment in ql-docs'
        }

        It 'It should retain the comment in shortcodes' {
            $testSettingsFile | Should -FileContentMatch '# with a comment in GitHub'
        }
    }
    Context 'When adding shortcodes to the settings file' -ForEach @(
        @{
            Section = 'shortcodes'
            Table = @{
                id = 'update'
                uri = 'https://updated.uri'
                name = 'updated'
                type = 'test'
            }
        }
    ) {
        BeforeAll {
            $testSettingsFile = (Join-Path $TestDrive 'setquicklinkitem.psd1')

            function Get-QuickLinkFilePath {}

            Mock -CommandName Get-QuickLinkFilePath -MockWith { return $testSettingsFile }

            $settingsContent = @'
@{
config     = @{
    shortcode = @{ start = '['; end = ':]' }
}
shortcodes = @(
    @{
        # with a comment in GitHub
        id   = 'gh'
        name = 'GitHub'
        uri  = 'https://github.com/'
        type = 'web'
    }
)
links      = @(
    @{
        # with a comment in ql-docs
        name = 'ql-docs'
        uri  = '[gh:]aldrichtr/PSQuickLinks/blob/main/docs'
        tags = @(
            'docs'
            )
    }
)
}
'@
            $settingsContent | Set-Content $testSettingsFile

            #! $_ is the hashtable of values in the ForEach which we splat to the function
            Add-QuickLinkItem @_

            $newSettingsTable = Import-Psd $testSettingsFile
        }

        It 'It should have two shortcodes listed' {
            $newSettingsTable.shortcodes.Count | Should -Be 2
        }

        It 'It should have a shortcode with the name updated' {
            $newSettingsTable.shortcodes | Where-Object name -like 'updated' | Should -Not -BeNullOrEmpty
        }

        It 'It should have a shortcode with the name GitHub' {
            $newSettingsTable.shortcodes | Where-Object name -like 'GitHub' | Should -Not -BeNullOrEmpty
        }

        It 'It should retain the comment in links' {
            $testSettingsFile | Should -FileContentMatch '# with a comment in ql-docs'
        }

        It 'It should retain the comment in shortcodes' {
            $testSettingsFile | Should -FileContentMatch '# with a comment in GitHub'
        }
    }
}
