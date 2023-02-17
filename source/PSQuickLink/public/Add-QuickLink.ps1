
function Add-QuickLink {
    [CmdletBinding()]
    param(
        # The name to use
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name,

        # The uri to use
        [Parameter(
            Position = 1,
            ValueFromPipelineByPropertyName
        )]
        [string]$Uri,

        # The tags to use
        [Parameter(
            Position = 2,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$Tags
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        try {
            $null = Add-QuickLinkItem -Section links -Table $PSBoundParameters
        } catch {
            throw "Could not add quicklink '$Name'`n$_"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
