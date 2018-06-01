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
    $BootstrapURL,
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

function CreateDcosConfig($fileName)
{
    $config = "bootstrap_url: http://${BootstrapIP}:8086
cluster_name: azure-dcos
exhibitor_storage_backend: static
master_discovery: static
oauth_enabled: BOOTSTRAP_OAUTH_ENABLED
ip_detect_public_filename: genconf/ip-detect.ps1
master_list:
MASTER_IP_LIST
resolvers:
- 168.63.129.16
- 8.8.4.4
- 8.8.8.8
"

    Set-Content -Path $fileName -Value $config
}

function CreateIpDetect($fileName)
{
    $content = '$headers = @{"Metadata" = "true"}
    $r = Invoke-WebRequest -headers $headers "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-04-02&format=text" -UseBasicParsing
    $r.Content'

    Set-Content -Path $fileName -Value $content
}

try {
    Write-Log "Setting up Windows bootstrap node. BootstrapURL:$BootstrapURL BootstrapIP:$BootstrapIP"

    New-item -itemtype directory -erroraction silentlycontinue c:\temp
    cd c:\temp
    New-item -itemtype directory -erroraction silentlycontinue c:\temp\genconf
    CreateDcosConfig "c:\temp\genconf\config.yaml"
    CreateIpDetect "c:\temp\genconf\ip-detect.ps1"
    & Curl.exe $BootstrapURL -o c:\temp\dcos_generate_config.windows.tar.xz
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to download $BootstrapURL"
    }
    & tar -xvf .\dcos_generate_config.windows.tar.xz
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to untar $BootstrapURL"
    }
    & .\install_bootstrap_windows.ps1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to run install_bootstrap_windows.ps1"
    }
} catch {
    Write-Log "Failed to provision Windows bootstrap node: $_"
    exit 1
}

Write-Log "Successfully provisioned Windows bootstrap node"
exit 0
