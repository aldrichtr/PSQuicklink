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

Describe 'Testing the public function Expand-LinkShortCode' -Tag @('unit', 'Expand-LinkShortCode') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Expand-LinkShortCode'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }
    Context 'When a shortcode is used in <uri>' -ForEach @(
        @{ Uri = '[gh:]aldrichtr/PSQuickLinks'; Result = 'https://github.com/aldrichtr/PSQuickLinks' }
    ) {
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
        }

        It 'Should expand to <Result> using the pipeline' {
            ($Uri | Expand-LinkShortCode) | Should -BeLikeExactly $Result
        }
    }

}
