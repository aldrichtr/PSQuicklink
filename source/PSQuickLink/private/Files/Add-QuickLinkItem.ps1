
function Add-QuickLinkItem {
    [CmdletBinding()]
    param(
        # The Section to add the table to
        [Parameter(
        )]
        [ValidateSet('config', 'shortcodes', 'links')]
        [string]$Section,

        # The hashtable to add
        [Parameter(
        )]
        [hashtable]$Table
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "`n$('-' * 80)`n-- Process start $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $settingsFile = Get-QuickLinkFilePath
        [xml]$doc = Import-PsdXml $settingsFile
        $newLine = $doc.CreateElement('NewLine')

        if ($null -ne $doc) {
            switch ($Section) {
                'config' {
                    # config is a hashtable so the inner xml is a Table
                    $xpath = 'Data/Table/Item[@Key="config"]/Table'
                }
                # shortcodes is an array of hashtables so the inner xml is an Array
                'shortcodes' {
                    $xpath = 'Data/Table/Item[@Key="shortcodes"]/Array'
                }
                # links is an array of hashtables so the inner xml is an Array
                'links' {
                    $xpath = 'Data/Table/Item[@Key="links"]/Array'
                }
            }

            $sectionNode = $doc.SelectSingleNode($xpath)
            if ($null -ne $sectionNode) {
                #! Creating an XML representation of a hashtable is a two step process
                #! first, ConvertTo-Psd creates a string representation
                #! then the string is converted to XML by Convert-PsdToXml
                $newElement = $Table | ConvertTo-Psd | Convert-PsdToXml

                #! The XML has an outer 'Data' Element, we want the inner table
                $tableElement = $newElement.SelectSingleNode('//Table')

                #! In order to append it, it must be part of the same document
                #
                $importedElement = $doc.ImportNode($tableElement, $true)
                #! now we add the table to the section followed by a newline
                $sectionNode.AppendChild($importedElement).AppendChild($newLine)

                #! finally, we export the new XML document back to the psd1
                Export-PsdXml -Path $settingsFile -Xml $doc
            }
        }

        Write-Debug "`n$('-' * 80)`n-- Process end $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
