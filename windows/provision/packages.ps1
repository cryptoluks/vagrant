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

# Install chocolatey and packages
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation
choco install --no-progress --failonstderr firefox git notepadplusplus imageglass python 7zip vscode sysinternals wireshark winscp microsoft-teams

# Install Guest Additions
Write-Host 'Importing the Oracle certificate as a Trusted Publisher...'
D:\cert\VBoxCertUtil.exe add-trusted-publisher D:\cert\vbox-sha1.cer

Write-Host 'Installing the VirtualBox Guest Additions...'
D:\VBoxWindowsAdditions-amd64.exe /S | Out-String -Stream

# Remove temporary files but not packer generated ones
'C:\tmp','C:\Windows\Temp',$env:TEMP | ForEach-Object {
    Get-ChildItem $_ -Exclude 'packer-*' -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}
