<#
  One-shot Windows setup for three free, open-source AI video tools:
    1. MoneyPrinterTurbo  (harry0703/MoneyPrinterTurbo) - topic/keyword -> short video
    2. SupoClip           (FujiwaraChoki/supoclip)      - long video -> viral shorts (OpusClip alternative)
    3. Freefield          (neuregex/freefield)          - 120 image/video/VFX/audio apps on ComfyUI

  Run in PowerShell (normal user is fine; winget will ask for admin when needed):
    Set-ExecutionPolicy -Scope Process Bypass -Force
    .\setup.ps1                 # install all three
    .\setup.ps1 -Skip Freefield # skip one (MoneyPrinterTurbo, SupoClip, Freefield)
#>
param(
  [string]$InstallDir = "$env:USERPROFILE\ai-tools",
  [string[]]$Skip = @()
)
$ErrorActionPreference = 'Stop'

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Has($cmd)  { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
              [Environment]::GetEnvironmentVariable('Path','User')
}
function WingetInstall($id) {
  winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
  Refresh-Path
}

if (-not (Has winget)) {
  throw "winget not found. Install 'App Installer' from the Microsoft Store, then re-run."
}

# ---------- prerequisites ----------
Step "Checking prerequisites (Git, Python 3.11, Node 22, Docker Desktop)"
if (-not (Has git)) { WingetInstall 'Git.Git' }

$py = $null
try { $py = (& py -3.11 -c "import sys;print(sys.executable)" 2>$null) } catch {}
if (-not $py) { WingetInstall 'Python.Python.3.11'; $py = (& py -3.11 -c "import sys;print(sys.executable)") }
Write-Host "Python 3.11: $py"

if ($Skip -notcontains 'Freefield') {
  $nodeOk = $false
  if (Has node) { $v = [version]((node -v).TrimStart('v')); $nodeOk = $v -ge [version]'22.6.0' }
  if (-not $nodeOk) { WingetInstall 'OpenJS.NodeJS.LTS' }
}

if ($Skip -notcontains 'SupoClip') {
  if (-not (Has docker)) {
    WingetInstall 'Docker.DockerDesktop'
    Write-Warning "Docker Desktop was just installed. Start it once (it may ask to enable WSL2 and reboot)."
  }
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Set-Location $InstallDir

function Clone($repo, $dir) {
  if (Test-Path "$dir\.git") { git -C $dir pull --ff-only } else { git clone --depth 1 "https://github.com/$repo.git" $dir }
}

# ---------- 1. MoneyPrinterTurbo ----------
if ($Skip -notcontains 'MoneyPrinterTurbo') {
  Step "Installing MoneyPrinterTurbo (official PyPI package 'mpt')"
  $mpt = "$InstallDir\MoneyPrinterTurbo"
  New-Item -ItemType Directory -Force -Path $mpt | Out-Null
  if (-not (Test-Path "$mpt\.venv")) { & py -3.11 -m venv "$mpt\.venv" }
  & "$mpt\.venv\Scripts\python.exe" -m pip install --upgrade pip
  & "$mpt\.venv\Scripts\python.exe" -m pip install --upgrade mpt
}

# ---------- 2. SupoClip ----------
if ($Skip -notcontains 'SupoClip') {
  Step "Downloading SupoClip"
  Clone 'FujiwaraChoki/supoclip' "$InstallDir\supoclip"
  if (-not (Test-Path "$InstallDir\supoclip\.env")) {
    Copy-Item "$InstallDir\supoclip\.env.example" "$InstallDir\supoclip\.env"
    Write-Host "Created supoclip\.env - add your API keys there before first start (see README)."
  }
}

# ---------- 3. Freefield ----------
if ($Skip -notcontains 'Freefield') {
  Step "Downloading Freefield"
  Clone 'neuregex/freefield' "$InstallDir\freefield"
  Push-Location "$InstallDir\freefield"
  npm install
  & py -3.11 -m pip install --user modal
  Write-Host "`nFreefield doctor (what is still missing):" -ForegroundColor Yellow
  & py -3.11 tools/doctor.py
  Pop-Location
}

# ---------- launchers ----------
Step "Copying launchers to $InstallDir"
Copy-Item "$PSScriptRoot\start-*.bat" $InstallDir -Force -ErrorAction SilentlyContinue

Write-Host "`nDone. Installed into $InstallDir" -ForegroundColor Green
Write-Host "Next: read pc-setup\README.md for the API keys each tool needs, then double-click a start-*.bat."
