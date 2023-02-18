
function New-QuickLink {
    <#
    .SYNOPSIS
        Create a new quicklink object
    .DESCRIPTION
        Create a [Quicklink] object
    #>
    [CmdletBinding()]
    param(
        # The name to use
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [string]$Name,

        # The uri to use
        [Parameter(
            Position = 1
        )]
        [string]$Uri,

        # The tags to use
        [Parameter(
            Position = 2
        )]
        [string[]]$Tags
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        [PSCustomObject]@{
            PSTypeName = 'QuickLink'
            name       = $Name ?? ''
            uri        = $Uri ?? ''
            tags       = $Tags ?? @()
        } | Write-Output
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
