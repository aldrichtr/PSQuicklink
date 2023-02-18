
function Expand-LinkShortCode {
    <#
    .SYNOPSIS
        Convert a LinkShortCode to it's value
    .EXAMPLE
        ConvertFrom-LinkShortCode '[gh:]aldrichtr/dotfiles

        https://github.com/aldrichtr/dotfiles
    #>
    [CmdletBinding()]
    param(
        # The String to convert link ShortCodes in
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Uri
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"

        function replaceSpecial {
            <#
            .SYNOPSIS
                Escape regex special characters ('[' to '\]')
            .DESCRIPTION
                [regex]::Escape does not escape a single ']' so I need to do it
                this way
            #>
            param(
                [string]$s
            )
            $s = $s -replace '\[', '\[' -replace '\]', '\]'
            $s = $s -replace '\{', '\{' -replace '\}', '\}'
            $s = $s -replace '\(', '\(' -replace '\)', '\)'
            $s | Write-Output
        }

        $settings = Import-QuickLinkFile
        $config = $settings.config.shortcode

        if ($null -eq $config) {
            Write-Verbose 'Could not import shortcode settings'
            $config = @{}
        }

        if (([string]::IsNullorEmpty($config.start)) -or
            ([string]::IsNullorEmpty($config.end))) {
            Write-Verbose 'Could not find shortcode marker config in Quicklinks file'
            Write-Verbose "Using default '[' and ':]'"
            $config['start'] = '['
            $config['end'] = ':]'
        }

        Write-Debug "Shortcode markers are '$($config.start)' and '$($config.end)'"

        $shortCodeFinder = ((
            (replaceSpecial $config.start),
                '(?<scode>\w+)',
            (replaceSpecial $config.end)
            ) -join '')

    }
    process {
        Write-Debug "Using '$shortCodeFinder' to find shortcode in '$Uri'"
        $null = $Uri -match $shortCodeFinder
        if ($Matches.count -gt 0) {
            Write-Debug "- Matches:"
            Write-Debug "  0 : $($Matches.0)"
            Write-Debug "  1 : $($Matches.1)"
            Write-Debug "  scode : $($Matches.scode)"

            $found = $Matches.scode

            Write-Debug "in $Uri we found '$found'"
            <#------------------------------------------------------------------
              Now that we have a shortcode id, look up the details and replace
              the shortcode with the uri if present
            ------------------------------------------------------------------#>
            if ($settings.ContainsKey('shortcodes')) {
                $shortCode = $settings.shortcodes | Where-Object 'id' -EQ $found

                if ([string]::IsNullorEmpty($shortCode)) {
                    Write-Warning "$found does not resolve to a link shortCode"
                } else {
                    Write-Debug "Replacing '$shortCodeFinder' with '$($shortCode.uri)'"
                    $Uri = $Uri -replace $shortCodeFinder, $shortCode.uri
                    Write-Debug " - Uri is now '$Uri'"
                }
            } else {
                Write-Verbose 'No shortcodes defined in Quicklinks file'
            }
        } else {
            Write-Debug 'did not find a match'
        }
        $Uri | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
