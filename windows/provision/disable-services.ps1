Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
trap {
    Write-Host
    Write-Host "ERROR: $_"
    Write-Host (($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1')
    Write-Host (($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1')
    Write-Host
    Write-Host 'Sleeping for 60m to give you time to look around the virtual machine before self-destruction...'
    Start-Sleep -Seconds (60*60)
    Exit 1
}

function New-Directory($path) {
    $p, $components = $path -split '[\\/]'
    $components | ForEach-Object {
        $p = "$p\$_"
        if (!(Test-Path $p)) {
            New-Item -ItemType Directory $p | Out-Null
        }
    }
    $null
}

$auPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
New-Directory $auPath 
New-ItemProperty `
    -Path $auPath `
    -Name NoAutoUpdate `
    -Value 1 `
    -PropertyType DWORD `
    -Force `
    | Out-Null

New-ItemProperty `
    -Path $auPath `
    -Name AUOptions `
    -Value 2 `
    -PropertyType DWORD `
    -Force `
    | Out-Null

$deliveryOptimizationPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config'
if (Test-Path $deliveryOptimizationPath) {
    New-ItemProperty `
        -Path $deliveryOptimizationPath `
        -Name DODownloadMode `
        -Value 0 `
        -PropertyType DWORD `
        -Force `
        | Out-Null
}

Set-MpPreference -DisableRealtimeMonitoring $true -ExclusionPath @('C:\', 'D:\', 'E:\')
Set-ItemProperty -Path 'HKLM:/SOFTWARE/Policies/Microsoft/Windows Defender' -Name DisableAntiSpyware -Value 1
