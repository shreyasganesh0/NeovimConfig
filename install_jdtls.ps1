# Install the latest JDTLS into the path that nvim's stdpath("data") resolves to.
# Run from PowerShell: .\install_jdtls.ps1

$ErrorActionPreference = "Stop"

# stdpath("data") on Windows resolves to %LOCALAPPDATA%\nvim-data
$JdtlsDir = Join-Path $env:LOCALAPPDATA "nvim-data\mason\packages\jdtls"

# Check Java
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Error "Java 17+ is required. Install from https://adoptium.net or via winget:`n  winget install EclipseAdoptium.Temurin.17.JDK"
    exit 1
}

Write-Host "Java  : $(java --version 2>&1 | Select-Object -First 1)"
Write-Host "Target: $JdtlsDir"

# Fetch latest release tarball URL from GitHub
$Release = Invoke-RestMethod "https://api.github.com/repos/eclipse-jdtls/eclipse.jdt.ls/releases/latest"
$TarballUrl = ($Release.assets | Where-Object { $_.name -like "*.tar.gz" } | Select-Object -First 1).browser_download_url

if (-not $TarballUrl) {
    Write-Error "Could not find tarball in latest JDTLS release."
    exit 1
}

Write-Host "URL   : $TarballUrl"

# Prepare destination
New-Item -ItemType Directory -Force -Path $JdtlsDir | Out-Null
Set-Location $JdtlsDir

# Clean existing install
Remove-Item -Recurse -Force plugins, config_win -ErrorAction SilentlyContinue

# Download
$TarballPath = Join-Path $JdtlsDir "jdtls.tar.gz"
Write-Host "Downloading..."
Invoke-WebRequest -Uri $TarballUrl -OutFile $TarballPath

# Extract (requires tar, available on Windows 10 1803+)
Write-Host "Extracting..."
tar -xzf $TarballPath
Remove-Item $TarballPath

# Verify
$Launcher = Get-ChildItem -Path "plugins" -Filter "org.eclipse.equinox.launcher_*.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $Launcher) {
    Write-Error "Launcher jar not found after extraction."
    exit 1
}

if (-not (Test-Path "config_win")) {
    Write-Warning "config_win directory not found. Available config dirs:"
    Get-ChildItem -Directory -Filter "config_*" | ForEach-Object { Write-Host "  $_" }
}

Write-Host ""
Write-Host "JDTLS installed successfully."
Write-Host "  Launcher : $JdtlsDir\plugins\$($Launcher.Name)"
Write-Host "  Config   : $JdtlsDir\config_win"
