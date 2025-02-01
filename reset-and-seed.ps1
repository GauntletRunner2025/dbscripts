# Stop execution on error
$ErrorActionPreference = "Stop"

# Get the project root (one level up from scripts directory)
$projectRoot = Split-Path $PSScriptRoot -Parent

# Load environment variables from .env.local
$envFile = "$projectRoot/.env.local"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($key, $value)
        }
    }
}

# Change to project root directory
Push-Location $projectRoot

try {
    Write-Host "0. Setting migration .sql timestamps..." -ForegroundColor Cyan
    & "$PSScriptRoot/set-migration-timestamps.ps1"

    Write-Host "1. Resetting database..." -ForegroundColor Cyan
    npx supabase db reset

    Write-Host "2. Seeding users..." -ForegroundColor Cyan
    & "$PSScriptRoot/seed-users.ps1"

    Write-Host "3. Updating schema..." -ForegroundColor Cyan
    & "$PSScriptRoot/update-schema.ps1"

    Write-Host "Done!" -ForegroundColor Green
}
finally {
    # Always restore original directory
    Pop-Location
}