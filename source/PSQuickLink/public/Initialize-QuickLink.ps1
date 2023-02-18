
function Initialize-QuickLink {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('PSPath')]
        [string]$Path,

        # Overwrite the file if it already exists
        [Parameter(
        )]
        [switch]$Force
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $templateFile = (Join-Path $MyInvocation.MyCommand.Module.Path 'QuickLinksTemplate.txt')
    }
    process {
        $quicklinkFile = Get-QuickLinkFilePath @PSBoundParameters

        if ((-not(Test-Path $quicklinkFile)) -or ($Force)) {
            Write-Verbose "Writing '$quicklinkFile'"
            Copy-Item -Path $templateFile -Destination $quicklinkFile
        } else {
            throw "$quicklinkFile already exists.  Use -Force to overwrite"
        }

    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
