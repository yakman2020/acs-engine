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
    $BootstrapIP
)

$global:BootstrapInstallDir = "C:\AzureData"

filter Timestamp {"[$(Get-Date -Format o)] $_"}

function Write-Log($message)
{
    $msg = $message | Timestamp
    Write-Output $msg
}

try {
    Write-Log "Setting up Windows Agent node. BootstrapIP:$BootstrapIP"
    Write-Log "Current user is $env:username"

    # prime the credential cache

    $unattend_txt = Get-Content "c:\unattend.xml"
    $unattend =  [System.Xml.XmlDocument] $unattend_txt
    $password = $unattend.unattend.settings.component.UserAccounts.AdministratorPassword.Value

    & cmdkey /generic:"dcos/app" /user:"$env:userdomain\$env:username" /pass:"$password"

    $dcosInstallUrl = "http://${BootstrapIP}:8086/dcos_install.ps1"
    & curl.exe $dcosInstallUrl -o $global:BootstrapInstallDir\dcos_install.ps1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to download $dcosInstallUrl"
    }
    & $global:BootstrapInstallDir\dcos_install.ps1 ROLENAME
    if ($LASTEXITCODE -ne 0) {
        throw "Failed run DC/OS install script"
    }
} catch {
    Write-Log "Failed to provision Windows agent node: $_"
    exit 1
}

Write-Log "Successfully provisioned Windows agent node"
exit 0
