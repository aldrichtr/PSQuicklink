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

Describe "Testing the private function Get-QuickLinkFilePath"  -Tag @('unit', 'Get-QuickLinkFilePath') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Get-QuickLinkFilePath' -ErrorAction SilentlyContinue
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When the QuickLink variables are set' {
        BeforeAll {
            $envPath = (Join-Path $TestDrive 'env\.quicklinks.psd1')
            $varPath = (Join-Path $TestDrive  'var\.quicklinks.psd1')
        }

        AfterEach {
            $env:QUICKLINK_FILE = $null
            Remove-Variable PSQuickLinkFile -Force -ErrorAction SilentlyContinue
        }

        It 'Should use the environment variable`$env:QUICKLINK_FILE' {
            $env:QUICKLINK_FILE = $envPath
            Get-QuickLinkFilePath | Should -Be $envPath
        }

        It 'Should use the Global variable`$PSQuickLinkFile' {
            $PSQuickLinkFile = $varPath
            Get-QuickLinkFilePath | Should -Be $varPath
        }


    }
}
