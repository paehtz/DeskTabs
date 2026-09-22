<#
  DeskTabs setup / updater / uninstaller

  Installs the latest DeskTabs release to %LOCALAPPDATA%\DeskTabs, adds an
  autostart entry and launches it. Run it again any time to update: your
  settings, icon cache and time logs are kept.

  Usage (PowerShell):
    irm https://raw.githubusercontent.com/paehtz/DeskTabs/main/setup.ps1 | iex

  Or download this file and run it:
    .\setup.ps1              install or update
    .\setup.ps1 -NoAutostart install without the autostart entry
    .\setup.ps1 -NoLaunch    install without starting DeskTabs afterwards
    .\setup.ps1 -Uninstall   remove DeskTabs (asks what to do with your settings)
#>

[CmdletBinding()]
param(
    [switch] $Uninstall,
    [switch] $NoAutostart,
    [switch] $NoLaunch,
    [switch] $KeepSettings,
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo       = 'paehtz/DeskTabs'
$installDir = Join-Path $env:LOCALAPPDATA 'DeskTabs'
$startup    = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')
$lnk        = Join-Path $startup 'DeskTabs.lnk'
# Files that belong to the user, not to the release
$userFiles  = @('settings.ini', 'icons', 'desktop-log_*.csv', '_error.log')

function Stop-DeskTabs {
    $procs = Get-Process DeskTabs -ErrorAction SilentlyContinue
    if ($procs) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 400
    }
}

# ---------------------------------------------------------------- uninstall --
if ($Uninstall) {
    Write-Host "Removing DeskTabs..." -ForegroundColor Cyan
    Stop-DeskTabs

    if (Test-Path $lnk) {
        Remove-Item $lnk -Force
        Write-Host "  autostart entry removed"
    }

    if (Test-Path $installDir) {
        $keep = $KeepSettings
        if (-not $keep -and -not $Quiet) {
            $answer = Read-Host "  Keep your settings, icons and time logs? [Y/n]"
            $keep = ($answer -notmatch '^[nN]')
        }
        if ($keep) {
            $backup = Join-Path ([System.IO.Path]::GetTempPath()) ("DeskTabs-userdata-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
            New-Item -ItemType Directory -Force -Path $backup | Out-Null
            foreach ($pattern in $userFiles) {
                Get-ChildItem -Path $installDir -Filter $pattern -ErrorAction SilentlyContinue |
                    ForEach-Object { Move-Item $_.FullName (Join-Path $backup $_.Name) -Force }
            }
            Write-Host "  your files were moved to: $backup"
        }
        Remove-Item $installDir -Recurse -Force
        Write-Host "  program folder removed: $installDir"
    } else {
        Write-Host "  nothing installed at $installDir"
    }

    Write-Host ""
    Write-Host "DeskTabs removed. Nothing else was changed on your system." -ForegroundColor Green
    Write-Host "(DeskTabs never writes to the registry and installs nothing outside that folder.)"
    return
}

# ------------------------------------------------------ install or update ----
Write-Host "Looking up the latest DeskTabs release..." -ForegroundColor Cyan
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers @{ 'User-Agent' = 'DeskTabs-setup' }
$asset   = $release.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
if (-not $asset) { throw "No .zip asset found in the latest release ($($release.tag_name))." }

Write-Host "Found $($release.tag_name): $($asset.name)" -ForegroundColor Cyan

$tmp = Join-Path $env:TEMP $asset.name
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -Headers @{ 'User-Agent' = 'DeskTabs-setup' }

Stop-DeskTabs

# Keep the user's own files across an update
$stash = $null
if (Test-Path $installDir) {
    $stash = Join-Path ([System.IO.Path]::GetTempPath()) ("DeskTabs-keep-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Force -Path $stash | Out-Null
    $moved = 0
    foreach ($pattern in $userFiles) {
        Get-ChildItem -Path $installDir -Filter $pattern -ErrorAction SilentlyContinue |
            ForEach-Object { Move-Item $_.FullName (Join-Path $stash $_.Name) -Force; $moved++ }
    }
    if ($moved) { Write-Host "Keeping your settings, icon cache and time logs..." -ForegroundColor Cyan }
    Remove-Item $installDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Expand-Archive -Path $tmp -DestinationPath $installDir -Force
Remove-Item $tmp -Force

# Releases may ship the files inside a versioned folder - flatten that
$exe = Get-ChildItem $installDir -Recurse -Filter 'DeskTabs*.exe' | Select-Object -First 1
if (-not $exe) { throw "No DeskTabs executable found after extraction." }
if ($exe.DirectoryName -ne $installDir) {
    Get-ChildItem -Path $exe.DirectoryName -Force | ForEach-Object { Move-Item $_.FullName (Join-Path $installDir $_.Name) -Force }
    Remove-Item $exe.DirectoryName -Recurse -Force
    $exe = Get-ChildItem $installDir -Filter 'DeskTabs*.exe' | Select-Object -First 1
}

# Put the user's files back
if ($stash) {
    Get-ChildItem -Path $stash -Force | ForEach-Object { Move-Item $_.FullName (Join-Path $installDir $_.Name) -Force }
    Remove-Item $stash -Recurse -Force
}

if (-not $NoAutostart) {
    $sh = New-Object -ComObject WScript.Shell
    $sc = $sh.CreateShortcut($lnk)
    $sc.TargetPath       = $exe.FullName
    $sc.WorkingDirectory = $installDir
    $sc.Description      = 'DeskTabs - desktop bar for Windows 11'
    $sc.Save()
}

if (-not $NoLaunch) { Start-Process -FilePath $exe.FullName -WorkingDirectory $installDir }

Write-Host ""
Write-Host "DeskTabs $($release.tag_name) installed to:" -ForegroundColor Green
Write-Host "  $installDir"
if (-not $NoAutostart) { Write-Host "Autostart entry created." -ForegroundColor Green }
if (-not $NoLaunch)    { Write-Host "DeskTabs is running. Right-click the bar for all settings." -ForegroundColor Green }
Write-Host ""
Write-Host "To remove it later:  .\setup.ps1 -Uninstall"
