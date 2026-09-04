param(
  [string]$SketchUpVersion = "2026"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$entryPoint = Join-Path $repoRoot "basegrid.rb"
$plugins = Join-Path $env:APPDATA "SketchUp\SketchUp $SketchUpVersion\SketchUp\Plugins"
$loader = Join-Path $plugins "basegrid_dev_loader.rb"

if (-not (Test-Path -LiteralPath $entryPoint)) {
  throw "Basegrid entry point was not found at $entryPoint"
}

New-Item -ItemType Directory -Force -Path $plugins | Out-Null
$rubyPath = $entryPoint.Replace("\", "/").Replace("'", "\\'")
$content = @(
  "# Development loader for Basegrid.",
  "load '$rubyPath'"
) -join "`r`n"

Set-Content -LiteralPath $loader -Value $content -Encoding UTF8
Write-Output "Installed $loader"
