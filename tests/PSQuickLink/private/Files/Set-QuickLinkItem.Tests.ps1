

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

Describe 'Testing private function Set-QuickLinkItem' -Tags @('unit', 'QuickLinkItem', 'Set' ) {
    Context 'The Set-QuickLinkItem command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Set-QuickLinkItem'
        }

        It 'It should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }

        It "It Should have a 'Section' parameter" {
            $command.Parameters['Section'].Count | Should -Be 1
        }
        It "It Should have a 'Name' parameter" {
            $command.Parameters['Name'].Count | Should -Be 1
        }
        It "It Should have a 'Key' parameter" {
            $command.Parameters['Key'].Count | Should -Be 1
        }
        It "It Should have a 'Value' parameter" {
            $command.Parameters['Value'].Count | Should -Be 1
        }
        It "It Should have a 'XPath' parameter" {
            $command.Parameters['XPath'].Count | Should -Be 1
        }
    }

    Context 'When given a configuration file' -Foreach @(
        @{ Section = 'links'; Name = 'ql-docs'; Key = 'uri'; Value = 'https://updated.uri' }
        @{ Section = 'shortcodes'; Name = 'GitHub'; Key = 'uri'; Value = 'https://updated.uri' }
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
            Set-QuickLinkItem @_
        }

        It 'It should have the <Section> <Name> <Key> updated to <Value>' {
            $testSettingsFile | Should -FileContentMatch "$Key = '$Value'" -Because "The file now contains`n$(Get-Content $testSettingsFile)`n"
        }

        It 'It should retain the comment in links' {
            $testSettingsFile | Should -FileContentMatch '# with a comment in ql-docs'
        }

        It 'It should retain the comment in shortcodes' {
            $testSettingsFile | Should -FileContentMatch '# with a comment in GitHub'
        }
    }
}
