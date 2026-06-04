<#
  DeskTabs setup / updater
  Downloads the latest DeskTabs release, installs it to %LOCALAPPDATA%\DeskTabs,
  adds an autostart entry and launches it. Run again any time to update.

  Usage (PowerShell):
    irm https://raw.githubusercontent.com/paehtz/DeskTabs/main/setup.ps1 | iex
  or download this file and run it.
#>

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo      = 'paehtz/DeskTabs'
$installDir = Join-Path $env:LOCALAPPDATA 'DeskTabs'
$startup   = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')

Write-Host "Looking up the latest DeskTabs release..." -ForegroundColor Cyan
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers @{ 'User-Agent' = 'DeskTabs-setup' }
$asset   = $release.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
if (-not $asset) { throw "No .zip asset found in the latest release ($($release.tag_name))." }

Write-Host "Found $($release.tag_name): $($asset.name)" -ForegroundColor Cyan

# Download to a temp file
$tmp = Join-Path $env:TEMP $asset.name
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -Headers @{ 'User-Agent' = 'DeskTabs-setup' }

# Stop a running instance so files are not locked
Get-Process DeskTabs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Fresh install dir
if (Test-Path $installDir) { Remove-Item $installDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# Extract
Expand-Archive -Path $tmp -DestinationPath $installDir -Force
Remove-Item $tmp -Force

# Locate the executable
$exe = Get-ChildItem $installDir -Recurse -Filter 'DeskTabs*.exe' | Select-Object -First 1
if (-not $exe) { throw "No DeskTabs executable found after extraction." }

# Autostart shortcut
$lnk = Join-Path $startup 'DeskTabs.lnk'
$sh  = New-Object -ComObject WScript.Shell
$sc  = $sh.CreateShortcut($lnk)
$sc.TargetPath       = $exe.FullName
$sc.WorkingDirectory = $exe.DirectoryName
$sc.Description       = 'DeskTabs - desktop bar for Windows 11'
$sc.Save()

# Launch now
Start-Process -FilePath $exe.FullName

Write-Host ""
Write-Host "DeskTabs $($release.tag_name) installed to:" -ForegroundColor Green
Write-Host "  $($exe.FullName)"
Write-Host "Autostart entry created. DeskTabs is now running." -ForegroundColor Green
