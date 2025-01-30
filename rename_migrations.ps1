# Stop execution on error
$ErrorActionPreference = "Stop"

# Get the project root (one level up from scripts directory)
$projectRoot = Split-Path $PSScriptRoot -Parent
$migrationsPath = Join-Path $projectRoot "supabase/migrations"

# Change to project root directory
Push-Location $projectRoot

try {
    # Get all .sql files in the migrations directory
    $files = Get-ChildItem -Path $migrationsPath -Filter "*.sql"
    
    foreach ($file in $files) {
        # Get creation time in the format YYYYMMDDHHMMSS
        $timestamp = (Get-ItemProperty -Path $file.FullName).CreationTime.ToString("yyyyMMddHHmmss")
        
        # Get the current filename without the numeric prefix
        $currentName = $file.Name
        $cleanName = $currentName -replace '^[\d_]+', ''
        
        # Create the new filename with the creation timestamp
        $newName = "${timestamp}_${cleanName}"
        
        # Only rename if the filename is different
        if ($currentName -ne $newName) {
            Write-Host "Renaming $currentName to $newName"
            Rename-Item -Path $file.FullName -NewName $newName -Force
        }
    }
    
    Write-Host "Migration files renamed successfully!" -ForegroundColor Green
} finally {
    # Return to original directory
    Pop-Location
}
