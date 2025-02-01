# Stop execution on error
$ErrorActionPreference = "Stop"

# Get the project root (one level up from scripts directory)
$projectRoot = Split-Path $PSScriptRoot -Parent

# Change to project root directory
Push-Location $projectRoot

try {
    Write-Host "Seeding users..." -ForegroundColor Cyan
    node --env-file=.env.local dbscripts/seed-users.js
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to seed users. Check the error messages above."
    }
    Write-Host "Users seeded successfully!" -ForegroundColor Green
} finally {
    # Return to original directory
    Pop-Location
}
