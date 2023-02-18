
function Set-QuickLink {
    <#
    .SYNOPSIS
        Modify a Quicklink
    #>
    [CmdletBinding()]
    param(
        # The name to use
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name,

        # Change the Name
        [Parameter(
            Position = 1
        )]
        [string]$NewName,


        # The uri to use
        [Parameter(
            Position = 2,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Uri,

        # The tags to use
        [Parameter(
            Position = 3,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$Tags
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $currentLink = Get-QuickLink -Name $Name -ErrorAction SilentlyContinue

        if ($null -ne $currentLink) {
            if ($PSBoundParameters.ContainsKey('Uri')) {
                $null = Set-QuickLinkItem -Section links -Name $Name -Key 'uri' -Value $Uri
            }
            if ($PSBoundParameters.ContainsKey('Tags')) {
                $null = Set-QuickLinkItem -Section links -Name $Name -Key 'tags' -Value $Tags
            }
            #! Reset the name last since that is the "key" that we use to search
            if ($PSBoundParameters.ContainsKey('NewName')) {
                $null = Set-QuickLinkItem -Section links -Name $Name -Key 'name' -Value $NewName
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
