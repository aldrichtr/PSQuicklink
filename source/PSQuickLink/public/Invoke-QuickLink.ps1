
function Invoke-QuickLink {
    [CmdletBinding()]
    param(
        # Quicklink object to open
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $link = Get-QuickLink @PSBoundParameters
        if ($null -ne $link) {
            Write-Debug "Found link $($link.name) with uri $($link.uri)"
            if ([string]::IsNullOrEmpty($link.uri)) {
                Write-Error "$($link.name) does not have a uri"
            } else {
                Start-Process -FilePath ($link.uri | Expand-LinkShortCode)
            }
        } else {
            throw "Could not find a link with name '$Name'"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
