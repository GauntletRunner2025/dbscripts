param(
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "documentation/schema.json"
)

# Stop execution on error
$ErrorActionPreference = "Stop"

# Get the project root (one level up from scripts directory)
$projectRoot = Split-Path $PSScriptRoot -Parent

# Change to project root directory
Push-Location $projectRoot

try {
    # Get the container ID
    if (-not $env:SUPABASE_PROJECT_ID) {
        Write-Error "SUPABASE_PROJECT_ID environment variable is not set"
        exit 1
    }
    $containerId = "supabase_db_$env:SUPABASE_PROJECT_ID"

    # Now run DefineSchema.sql and capture its output
    $schemaFile = Join-Path $PSScriptRoot "DefineSchema.sql"
    if (Test-Path $schemaFile) {
        Write-Host "Generating schema definition..."
        # Use -t to disable table formatting, -A for unaligned output mode
        $schemaJson = Get-Content $schemaFile | docker exec -i $containerId psql -U postgres -t -A
        
        # Create the documentation directory if it doesn't exist
        $docDir = Split-Path $OutputPath -Parent
        if (-not (Test-Path $docDir)) {
            New-Item -ItemType Directory -Path $docDir | Out-Null
        }
        
        # Save the schema JSON to documentation/schema.json
        $schemaJson | ConvertFrom-Json | ConvertTo-Json -Depth 100 | Out-File $OutputPath -Encoding UTF8
        
        Write-Host "Schema saved to $OutputPath"
    }
}
finally {
    # Always restore original directory
    Pop-Location
}