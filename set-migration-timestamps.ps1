# Stop execution on error
$ErrorActionPreference = "Stop"

# Get the project root (one level up from scripts directory)
$projectRoot = Split-Path $PSScriptRoot -Parent

# Change to project root directory
Push-Location $projectRoot

try {
    Write-Host "1. Renaming migrations based on creation time..." -ForegroundColor Cyan
    & "$PSScriptRoot/rename_migrations.ps1"
}
finally {
    # Always restore original directory
    Pop-Location
}