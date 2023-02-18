
function Get-LinkShortCode {
    [CmdletBinding(
        DefaultParameterSetName = 'ById'
    )]
    param(
        # The id of the shortcode to return
        [Parameter(
            ParameterSetName = 'ById',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Id,

        # The name of the shortcode to return
        [Parameter(
            ParameterSetName = 'ByName',
            ValueFromPipelineByPropertyName
        )]
        [string]$Name,

        # The type of shortcode to return
        [Parameter(
            ParameterSetName = 'ByType',
            ValueFromPipelineByPropertyName
        )]
        [string]$Type
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $config = Import-QuickLinkFile
        if (($null -ne $config) -and
            ($config.ContainsKey('shortcodes'))) {
            $shortcodes = $config.shortcodes
        } else {
            $shortcodes = @{}
        }
    }
    process {
        :scode foreach ($shortcode in $shortcodes) {
            if ($PSBoundParameters.ContainsKey('Id')) {
                if (-not($shortcode.id -like $Id)) {
                    continue scode
                }
            } elseif ($PSBoundParameters.ContainsKey('Name')) {
                if (-not($shortcode.name -like $Name)) {
                    continue scode
                }
            } elseif ($PSBoundParameters.ContainsKey('Type')) {
                if (-not($shortcode.type -like $Type)) {
                    continue scode
                }
            }

            $shortcode['PSTypeName'] = 'QuickLink.ShortCode'
            [PSCustomObject]$shortcode | Write-Output
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
