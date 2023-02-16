

function Get-QuickLink {
    <#
    .SYNOPSIS
        Return a list of site "QuickLinks" for use in the Quicklink system
    .DESCRIPTION
        A QuickLink is a link to a url in the form of a "shortcode".  For example, 'powershelldocs' refers to
        https://docs.microsoft.com/en-us/powershell/scripting/overview'. Quicklinks can also have tags to help
        categorize and group them.
    .EXAMPLE
        Get-QuickLink 'powergit'

        Return the QuickLink with the shortcode 'powergit'
    .EXAMPLE
        Get-QuickLink -Tag 'git'

        Return all Quicklinks that are tagged 'git'
    .COMPONENT
        QuickLink
    #>
    [CmdletBinding()]
    param(
        # Shortcode to return
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$Name,

        # Return links with the given tag(s)
        [Parameter(
        )]
        [string[]]$Tag
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config = Import-QuickLinkFile
        $links = $config.links
    }
    process {
        if ($PSBoundParameters.ContainsKey('Name')) {
            foreach ($link in $Name) {
                Write-Verbose "Looking for links with shortcode '$link'"
                $links | Where-Object -Property 'name' -Like $link | ForEach-Object {
                    $site = $_
                    $site['PSTypeName'] = 'QuickLinkInfo'
                    [PSCustomObject]$site | Write-Output
                }
            }
        } elseif ($PSBoundParameters.ContainsKey('Tag')) {
            # collect and dedup results
            $results = @()
            foreach ($t in $Tag) {
                Write-Verbose "Looking for links with tag '$t'"
                $links | Where-Object -Property 'tags' -Contains $t | ForEach-Object {
                    $site = $_
                    $site['PSTypeName'] = 'QuickLinkInfo'
                    [PSCustomObject]$site | Write-Output
                }
            }
        } else {
            Write-Verbose "Returning all links"
            $links | ForEach-Object {
                $site = $_
                $site['PSTypeName'] = 'QuickLinkInfo'
                [PSCustomObject]$site | Write-Output
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
