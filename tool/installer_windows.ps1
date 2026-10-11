# Compile la version de production de l'appli PC (Windows) et l'installe
# pour l'utilisateur courant, sans droits d'administrateur, avec un raccourci
# dans le menu Démarrer.
#
# Les DONNÉES ne sont jamais touchées : la base et les préférences sont dans
# %APPDATA%\fr.bouthon\cave, les sauvegardes dans Documents\Cave. Seuls les
# fichiers de l'appli (%LOCALAPPDATA%\Programs\Ma Cave) et le raccourci sont
# remplacés.
#
# PAS ENCORE ESSAYÉ (écrit sous Linux) : à vérifier sur le PC Windows.
#
# Usage (PowerShell, à la racine du projet) :
#   powershell -ExecutionPolicy Bypass -File tool\installer_windows.ps1
#   ... -NoBuild   (installe la version déjà compilée)
#   ... -Remove    (retire l'appli et le raccourci)
param([switch]$NoBuild, [switch]$Remove)
$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')
$bundle = 'build\windows\x64\runner\Release'
$appDir = Join-Path $env:LOCALAPPDATA 'Programs\Ma Cave'
$exe = Join-Path $appDir 'cave.exe'
$shortcut = Join-Path ([Environment]::GetFolderPath('Programs')) 'Ma Cave.lnk'

$running = Get-Process -Name cave -ErrorAction SilentlyContinue |
  Where-Object { $_.Path -eq $exe }
if ($running) {
  Write-Error ("Ma Cave est ouverte : fermez-la d'abord (sa sauvegarde de " +
    'fermeture doit pouvoir se faire).')
}

if ($Remove) {
  if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir }
  if (Test-Path $shortcut) { Remove-Item -Force $shortcut }
  Write-Host "Appli retirée. Données conservées dans $env:APPDATA\fr.bouthon\cave."
  exit 0
}

if (-not $NoBuild) {
  flutter build windows --release
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
if (-not (Test-Path (Join-Path $bundle 'cave.exe'))) {
  Write-Error "Version compilée introuvable ($bundle)."
}

# Copie à côté puis échange : une installation interrompue ne laisse jamais
# une appli à moitié copiée.
$newDir = "$appDir.new"
if (Test-Path $newDir) { Remove-Item -Recurse -Force $newDir }
New-Item -ItemType Directory -Force (Split-Path $appDir) | Out-Null
Copy-Item -Recurse $bundle $newDir
if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir }
Move-Item $newDir $appDir

# Raccourci du menu Démarrer (l'icône est celle de cave.exe).
$shell = New-Object -ComObject WScript.Shell
$link = $shell.CreateShortcut($shortcut)
$link.TargetPath = $exe
$link.WorkingDirectory = $appDir
$link.Description = 'Gérer les bouteilles de sa cave personnelle'
$link.Save()

Write-Host "Installé dans $appDir ; « Ma Cave » est dans le menu Démarrer."
