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

Write-Host 'Hardcode NetBIOS name to prevent long delays while resolving the vboxsrv...'
Write-Output @'
255.255.255.255 VBOXSVR #PRE
255.255.255.255 VBOXSRV #PRE
'@ | Out-File -Encoding ASCII -Append 'C:\Windows\System32\drivers\etc\lmhosts'

Write-Host 'Disable Sound Scheme...'
Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps" | Get-ChildItem | Get-ChildItem | Where-Object {$_.PSChildName -eq ".Current"} | Set-ItemProperty -Name "(Default)" -Value ""

Write-Host 'Hiding Taskbar Search box / button...'
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Type DWord -Value 0

Write-Host 'Changing default Explorer view to This PC...'
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -Type DWord -Value 1

Write-Host 'Showing This PC shortcut on desktop...'
If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu')) {
	New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Force | Out-Null
}
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Type DWord -Value 0
If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel')) {
	New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Force | Out-Null
}
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Type DWord -Value 0

Write-Host 'Showing User Folder shortcut on desktop...'
If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu')) {
	New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Force | Out-Null
}
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Type DWord -Value 0
If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel')) {
	New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Force | Out-Null
}
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Type DWord -Value 0

Write-Host 'Hiding Music icon from This PC...'
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}' -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}' -Recurse -ErrorAction SilentlyContinue

Write-Host 'Hiding Videos icon from This PC...'
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}' -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}' -Recurse -ErrorAction SilentlyContinue

Write-Host 'Hiding 3D Objects icon from This PC...'
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -Recurse -ErrorAction SilentlyContinue

Write-Host 'Adjusting visual effects for performance...'
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'DragFullWindows' -Type String -Value 0
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Type String -Value 0
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'UserPreferencesMask' -Type Binary -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'MinAnimate' -Type String -Value 0
Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name 'KeyboardDelay' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewAlphaSelect' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewShadow' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Type DWord -Value 3
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -Type DWord -Value 0

Write-Host 'Disable Telemetry...'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' -Name 'AllowTelemetry' -Type DWord -Value 0
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Type DWord -Value 0
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection' -Name 'AllowTelemetry' -Type DWord -Value 0

Write-Host 'Disable SmartScreen Filter...'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SmartScreenEnabled' -Type String -Value 'Off'
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost' -Name 'EnableWebContentEvaluation' -Type DWord -Value 0

Write-Host 'Disable Feedback...'
If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules')) {
	New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' -Force | Out-Null
}
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' -Name 'NumberOfSIUFInPeriod' -Type DWord -Value 0

Write-Host 'Disable Advertising ID...'
If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo')) {
	New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' | Out-Null
}
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Type DWord -Value 0
If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy')) {
	New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' | Out-Null
}
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' -Name 'TailoredExperiencesWithDiagnosticDataEnabled' -Type DWord -Value 0

Write-Host 'Disable Error reporting...'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' -Name 'Disabled' -Type DWord -Value 1

Write-Host 'Setting the vagrant account properties...'
$AdsAccountDisable      = 0x00002
$AdsNormalAccount       = 0x00200
$AdsDontExpirePassword  = 0x10000
$account = [ADSI]'WinNT://./vagrant'
$account.Userflags = $AdsNormalAccount -bor $AdsDontExpirePassword
$account.SetInfo()

Write-Host 'Setting the Administrator account properties...'
$account = [ADSI]'WinNT://./Administrator'
$account.Userflags = $AdsNormalAccount -bor $AdsDontExpirePassword -bor $AdsAccountDisable
$account.SetInfo()

Write-Host 'Disable auto logon...'
$autoLogonKeyPath = 'HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty -Path $autoLogonKeyPath -Name AutoAdminLogon -Value 0
@('DefaultDomainName', 'DefaultUserName', 'DefaultPassword') | ForEach-Object {
    Remove-ItemProperty -Path $autoLogonKeyPath -Name $_ -ErrorAction SilentlyContinue
}

Write-Host 'Disable Automatic Private IP Addressing (APIPA)...'
Set-ItemProperty `
    -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' `
    -Name IPAutoconfigurationEnabled `
    -Value 0

Write-Host 'Disable IPv6...'
Set-ItemProperty `
    -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' `
    -Name DisabledComponents `
    -Value 0xff

Write-Host 'Disable hibernation...'
powercfg /hibernate off

Write-Host 'Setting the power plan to high performance...'
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

Write-Host 'Show Explorer file extensions...'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0

Write-Host 'Disable energy saving options...'
powercfg.exe -x -monitor-timeout-ac 0
powercfg.exe -x -monitor-timeout-dc 0
powercfg.exe -x -disk-timeout-ac 0
powercfg.exe -x -disk-timeout-dc 0
powercfg.exe -x -standby-timeout-ac 0
powercfg.exe -x -standby-timeout-dc 0
powercfg.exe -x -hibernate-timeout-ac 0
powercfg.exe -x -hibernate-timeout-dc 0

Write-Host 'Disable the Windows Boot Manager menu...'
bcdedit /set '{bootmgr}' displaybootmenu no

Write-Host 'Set Windows dark theme...'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme -Value 0

Write-Host 'Disable people bar...'
New-Item -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
New-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name HidePeopleBar -Type DWord -Value 1

Write-Host 'Change wallpaper, lockscreen, and hide misc buttons in explorer...'
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name DisableLogonBackgroundImage -Type DWord -Value 1
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' -Name NoLockScreen -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallPaper -Value ''
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name AutoColorization -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\Control Panel\Colors' -Name Background -Value '59 110 165'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowTaskViewButton -Value 0
New-Item -Path 'HKCU:\Software\Microsoft\CTF\LangBar'
New-ItemProperty -Path 'HKCU:\Software\Microsoft\CTF\LangBar' -Name ShowStatus -Type DWord -Value 3

Write-Host 'Remove Shortcuts on Desktops...'
Remove-Item C:\Users\Public\Desktop\*lnk -Force -ErrorAction Ignore
Remove-Item C:\Users\Vagrant\Desktop\*lnk -Force -ErrorAction Ignore

Write-Host 'Set cleanmgr settings to all possible settings...'
reg import E:\cleanmgr-settings.reg

Write-Host 'Add Firefox policies.json for default settings/addons...'
mkdir "C:\Program Files\Mozilla Firefox\distribution"
Copy-Item E:\policies.json -Destination "C:\Program Files\Mozilla Firefox\distribution"

Write-Host 'Disable recovery agent, else sysprep will fail...'
reagentc /disable

Write-Host 'Enable Remote Desktop...'
Set-ItemProperty `
    -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
    -Name fDenyTSConnections `
    -Value 0
Enable-NetFirewallRule `
    -DisplayGroup 'Remote Desktop'
