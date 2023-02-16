
function Get-QuickLinkFilePath {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $DEFAULT_FILE = '.quicklinks.psd1'
        $DEFAULT_PATH = $env:USERPROFILE
    }
    process {
        if ($PSBoundParameters.ContainsKey('Path')) {
            Write-Debug "Alternate Quicklink file specified '$Path'"
            $Path | Write-Output
        } elseif ($null -ne $env:QUICKLINK_FILE) {
            $env:QUICKLINK_FILE | Write-Output
        } elseif ($null -ne $PSQuickLinkFile) {
            $PSQuickLinkFile | Write-Output
        } else {
            (Join-Path $DEFAULT_PATH $DEFAULT_FILE) | Write-Output
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }

}
