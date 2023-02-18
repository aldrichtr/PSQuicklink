
function Set-QuickLinkItem {
    <#
    .SYNOPSIS
        Update the Value of the Item specified in the Section with the Name
    .DESCRIPTION
        To update
        links = @(
            ...
            @{
                name = 'bing'
                uri  = 'https://www.bing.org' # <---- change this to .com
                tags = @()
             }
        )
        Set-QuickLinkItem 'links'

    #>
    [CmdletBinding(
        DefaultParameterSetName = 'AsKey'
    )]
    param(
        # The Section to add the table to
        [Parameter(
            ParameterSetName = 'AsKey',
            Position = 0
        )]
        [ValidateSet('config', 'shortcodes', 'links')]
        [string]$Section,

        # The unique name of the item
        [Parameter(
            ParameterSetName = 'AsKey',
            Position = 1
        )]
        [string]$Name,

        # The key to find the item
        [Parameter(
            ParameterSetName = 'AsKey',
            Position = 2
        )]
        [string]$Key,

        # Value to set the item to
        [Parameter(
            ParameterSetName = 'AsKey',
            Position = 3
        )]
        [string]$Value,

        # XPath to item to be updated
        [Parameter(
            ParameterSetName = 'AsXPath'
        )]
        [string]$XPath
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $settingsFile = Get-QuickLinkFilePath
        [xml]$doc = Import-PsdXml $settingsFile
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($null -ne $doc) {
            if (-not($PSBoundParameters.ContainsKey('XPath'))) {
                switch ($Section) {
                    'config' {
                        Write-Debug "Looking for $Key in config table"
                        # config is a hashtable so the inner xml is a Table
                        $XPath = 'Data/Table/Item[@Key="config"]/Table'
                        $configNode = $doc.SelectSingleNode($XPath)
                        if ($null -ne $configNode) {
                            $node = $configNode.SelectSingleNode( -join ('//Item[@Key"', $Key, '"]' ))

                        }
                    }
                    # shortcodes is an array of hashtables so the inner xml is an Array
                    'shortcodes' {
                        Write-Debug "Looking for item with name $Name in shortcodes array"
                        $XPath = 'Data/Table/Item[@Key="shortcodes"]/Array'
                        $shortCodeNode = $doc.SelectSingleNode($XPath)
                        $nameNode = $shortCodeNode.SelectSingleNode( -join ('//Item[@Key="name"]/String[text()="', $Name, '"]'))
                        if ($null -ne $nameNode) {
                            # Up one level for the ItemNode, and one to get to the table
                            $node = $nameNode.ParentNode.ParentNode
                        } else {
                            throw "Could not find shortcode with name $Name"
                        }
                    }
                    # links is an array of hashtables so the inner xml is an Array
                    'links' {
                        Write-Debug "Looking for item with name $Name in links array"
                        $linksNode = $doc.SelectSingleNode('Data/Table/Item[@Key="links"]/Array')
                        if ($null -ne $linksNode) {
                            Write-Debug 'Found the links node'
                            $nameNode = $linksNode.SelectSingleNode( -join ('//Item[@Key="name"]/String[text()="', $Name, '"]'))
                            if ($null -ne $nameNode) {
                                Write-Debug "Found the $Name node"
                                # Up one level for the ItemNode, and one to get to the table
                                $node = $nameNode.ParentNode.ParentNode
                            } else {
                                throw "Could not find link with name $Name"
                            }
                        } else {
                            throw "Could not find the 'links' table in settings"
                        }
                    }
                }
            } else {
                $node = $doc.SelectSingleNode($XPath)
            }


            if ($null -ne $node) {
                $keyXPath = ( -join ('Item[@Key="', $Key, '"]'))
                $item = $node.SelectSingleNode( $keyXPath )
                if ($null -ne $item) {
                    Write-Debug "Found the $Key item, setting value $Value"
                    Write-Debug "Before:`n $($item.OuterXml)"
                    Set-Psd $item $Value
                    Write-Debug "After:`n $($item.OuterXml)"
                    Export-PsdXml -Path $settingsFile -Xml $doc
                }
            } else {
                throw "Could not find the $Key item in $Section $Name"
            }
        }
        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
