<#
    .SYNOPSIS
        Provisions VM as a Windows bootstrap node.

    .DESCRIPTION
        Provisions VM as a Windows bootstrap node.

     Invoke by:
       
#>

[CmdletBinding(DefaultParameterSetName="Standard")]
param(
    [string]
    [ValidateNotNullOrEmpty()]
    $WindowsBootstrapURL
)

$global:BootstrapInstallDir = "C:\AzureData"

filter Timestamp {"$(Get-Date -Format o): $_"}


function
Write-Log($message)
{
    $msg = $message | Timestamp
    Write-Output $msg
}

Write-Log "Hello World! WindowsBootstrapURL=$WindowsBootstrapURL"
exit 0
