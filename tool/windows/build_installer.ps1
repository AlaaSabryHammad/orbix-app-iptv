# Builds Orbix for Windows (prod flavor) and packages it:
#   dist/Orbix-Setup-<version>-x64.exe   installer (Inno Setup 6+)
#   dist/Orbix-<version>-windows-x64.zip portable copy, runs without installing
#
#   powershell -ExecutionPolicy Bypass -File tool/windows/build_installer.ps1
#
# Needs: Developer Mode on (Flutter plugin symlinks), Visual Studio 2022 with
# "Desktop development with C++", and Inno Setup 6+ for the installer.
param(
  # Skip `flutter build` and package the existing Release folder.
  [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $root

$version = (Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9.]+)').Matches[0].Groups[1].Value
$release = Join-Path $root 'build\windows\x64\prod\runner\Release'
Write-Host "Orbix $version"

if (-not $SkipBuild) {
  # prod: no demo provider, no assets/demo (the default flavor is dev).
  flutter build windows --release --flavor prod
  if ($LASTEXITCODE -ne 0) { throw 'flutter build windows failed' }
}
if (-not (Test-Path (Join-Path $release 'Orbix.exe'))) { throw "No build in $release" }

# The Visual C++ runtime next to Orbix.exe (app-local), so it starts on PCs
# that never installed the VC++ Redistributable.
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$crt = Get-ChildItem (Join-Path $vs 'VC\Redist\MSVC') -Directory |
  Where-Object Name -Match '^\d' | Sort-Object { [version]$_.Name } | Select-Object -Last 1 |
  ForEach-Object { Join-Path $_.FullName 'x64\Microsoft.VC143.CRT' }
if (-not (Test-Path $crt)) { throw "VC++ runtime not found under $vs" }
Copy-Item (Join-Path $crt '*.dll') $release -Force

$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null

$zip = Join-Path $dist "Orbix-$version-windows-x64.zip"
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path (Join-Path $release '*') -DestinationPath $zip
Write-Host "Portable: $zip"

# Inno Setup 6 or later, newest first.
$iscc = Get-ChildItem "$env:ProgramFiles", "${env:ProgramFiles(x86)}", "$env:LOCALAPPDATA\Programs" -Directory -Filter 'Inno Setup *' -ErrorAction SilentlyContinue |
  Sort-Object { [int]($_.Name -replace '\D', '') } -Descending |
  ForEach-Object { Join-Path $_.FullName 'ISCC.exe' } | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) {
  Write-Warning 'Inno Setup is not installed (https://jrsoftware.org/isdl.php): skipped the installer.'
  exit 0
}
& $iscc /Qp "/DAppVersion=$version" "/DSourceDir=$release" (Join-Path $root 'windows\installer\orbix.iss')
if ($LASTEXITCODE -ne 0) { throw 'Inno Setup failed' }
Write-Host "Installer: $(Join-Path $dist "Orbix-Setup-$version-x64.exe")"
