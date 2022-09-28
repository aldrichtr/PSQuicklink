# PSAnnex QuickLink module

## SYNOPSIS

open a website from the commandline using a shortcode

## DESCRIPTION

A QuickLink is a shortcode => url mapping with some additional metadata.  Once set,
the url can be opened by calling Invoke-Quicklink <shortcode>

## EXAMPLE

Set-Quicklink psgallery https://www.powershellgallery.com
Invoke-Quicklink psgallery
# opens the default browser at the PowerShell Gallery website
