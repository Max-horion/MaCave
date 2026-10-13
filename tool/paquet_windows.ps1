# Construit l'installateur Windows de diffusion (lot 10) :
#   build\diffusion\MaCave-<version>-windows-setup.exe
# (nom fixé par docs\guide_installation.md ; version lue dans pubspec.yaml).
#
# Prérequis : Inno Setup 6 (https://jrsoftware.org/isdl.php), installé à son
# emplacement par défaut, ou ISCC.exe dans le PATH.
#
# Usage (PowerShell, à la racine du projet) :
#   powershell -ExecutionPolicy Bypass -File tool\paquet_windows.ps1
#   ... -NoBuild   (reprend la version déjà compilée)
param([switch]$NoBuild)
$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')
$line = Select-String -Path pubspec.yaml -Pattern '^version:\s*([^+\s]+)'
$version = $line.Matches[0].Groups[1].Value

$iscc = (Get-Command ISCC.exe -ErrorAction SilentlyContinue).Source
if (-not $iscc) {
  foreach ($dir in @("${env:ProgramFiles(x86)}\Inno Setup 6",
                     "$env:ProgramFiles\Inno Setup 6",
                     "$env:LOCALAPPDATA\Programs\Inno Setup 6")) {
    if (Test-Path "$dir\ISCC.exe") { $iscc = "$dir\ISCC.exe"; break }
  }
}
if (-not $iscc) {
  Write-Error 'Inno Setup 6 introuvable : https://jrsoftware.org/isdl.php'
}

if (-not $NoBuild) {
  flutter build windows --release
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
if (-not (Test-Path 'build\windows\x64\runner\Release\cave.exe')) {
  Write-Error 'Version compilée introuvable (build\windows\x64\runner\Release).'
}

& $iscc "/DAppVersion=$version" windows\packaging\MaCave.iss
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$setup = "build\diffusion\MaCave-$version-windows-setup.exe"
$size = [math]::Round((Get-Item $setup).Length / 1MB, 1)
Write-Host "Installateur : $setup ($size Mo)"
Get-FileHash -Algorithm SHA256 $setup | Format-List Hash
