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

#
# run automatic maintenance.

Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class Windows
{
    [DllImport("kernel32", SetLastError=true)]
    public static extern UInt64 GetTickCount64();

    public static TimeSpan GetUptime()
    {
        return TimeSpan.FromMilliseconds(GetTickCount64());
    }
}
'@

function Wait-Condition {
    param(
      [scriptblock]$Condition,
      [int]$DebounceSeconds=15
    )
    process {
        $begin = [Windows]::GetUptime()
        do {
            Start-Sleep -Seconds 3
            try {
              $result = &$Condition
            } catch {
              $result = $false
            }
            if (-not $result) {
                $begin = [Windows]::GetUptime()
                continue
            }
        } while ((([Windows]::GetUptime()) - $begin).TotalSeconds -lt $DebounceSeconds)
    }
}

function Get-ScheduledTasks() {
    $s = New-Object -ComObject 'Schedule.Service'
    try {
        $s.Connect()
        Get-ScheduledTasksInternal $s.GetFolder('\')
    } finally {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($s) | Out-Null
    }
}

function Get-ScheduledTasksInternal($Folder) {
    $Folder.GetTasks(0)
    $Folder.GetFolders(0) | ForEach-Object {
        Get-ScheduledTasksInternal $_
    }
}

function Test-IsMaintenanceTask([xml]$definition) {
    # see MaintenanceSettings (maintenanceSettingsType) Element at https://msdn.microsoft.com/en-us/library/windows/desktop/hh832151(v=vs.85).aspx
    $ns = New-Object System.Xml.XmlNamespaceManager($definition.NameTable)
    $ns.AddNamespace('t', $definition.DocumentElement.NamespaceURI)
    $null -ne $definition.SelectSingleNode("/t:Task/t:Settings/t:MaintenanceSettings", $ns)
}

Write-Host 'Running Automatic Maintenance...'
MSchedExe.exe Start
Wait-Condition {@(Get-ScheduledTasks | Where-Object {($_.State -ge 4) -and (Test-IsMaintenanceTask $_.XML)}).Count -eq 0} -DebounceSeconds 60


#
# generate the .net frameworks native images.
# NB this is normally done in the Automatic Maintenance step, but for
#    some reason, sometimes its not.
# see https://docs.microsoft.com/en-us/dotnet/framework/tools/ngen-exe-native-image-generator

Get-ChildItem "$env:windir\Microsoft.NET\*\*\ngen.exe" | ForEach-Object {
    Write-Host "Generating the .NET Framework native images with $_..."
    &$_ executeQueuedItems /nologo /silent
}


#
# remove temporary files.
# NB we ignore the packer generated files so it won't complain in the output.

Write-Host 'Stopping services that might interfere with temporary file removal...'
function Stop-ServiceForReal($name) {
    while ($true) {
        Stop-Service -ErrorAction SilentlyContinue $name
        if ((Get-Service $name).Status -eq 'Stopped') {
            break
        }
    }
}
Stop-ServiceForReal TrustedInstaller   # Windows Modules Installer
Stop-ServiceForReal wuauserv           # Windows Update
Stop-ServiceForReal BITS               # Background Intelligent Transfer Service
@(
    "$env:LOCALAPPDATA\Temp\*"
    "$env:windir\Temp\*"
    "$env:windir\Logs\*"
    "$env:windir\Panther\*"
    "$env:windir\WinSxS\ManifestCache\*"
    "$env:windir\SoftwareDistribution\Download"
) | Where-Object {Test-Path $_} | ForEach-Object {
    Write-Host "Removing temporary files $_..."
    takeown.exe /D Y /R /F $_ | Out-Null
    icacls.exe $_ /grant:r Administrators:F /T /C /Q 2>&1 | Out-Null
    Remove-Item $_ -Exclude 'packer-*' -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}
