Write-Host 'Downloading EjectVolumeMedia...'
$ejectVolumeMediaExeUrl = 'https://github.com/rgl/EjectVolumeMedia/releases/download/v1.0.0/EjectVolumeMedia.exe'
$ejectVolumeMediaExeHash = 'f7863394085e1b3c5aa999808b012fba577b4a027804ea292abf7962e5467ba0'
$ejectVolumeMediaExe = "$env:TEMP\EjectVolumeMedia.exe"
Invoke-WebRequest $ejectVolumeMediaExeUrl -OutFile $ejectVolumeMediaExe
$ejectVolumeMediaExeActualHash = (Get-FileHash $ejectVolumeMediaExe -Algorithm SHA256).Hash
if ($ejectVolumeMediaExeActualHash -ne $ejectVolumeMediaExeHash) {
    throw "the $ejectVolumeMediaExeUrl file hash $ejectVolumeMediaExeActualHash does not match the expected $ejectVolumeMediaExeHash"
}

Get-Volume | Where-Object {$_.DriveType -ne 'Fixed' -and $_.DriveLetter} | ForEach-Object {
    &$ejectVolumeMediaExe $_.DriveLetter
}
