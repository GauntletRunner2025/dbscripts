# Function to read .env file
function Get-EnvVariables {
    param (
        [string]$envFile
    )
    
    if (!(Test-Path $envFile)) {
        Write-Error "Environment file not found: $envFile"
        exit 1
    }

    $envVars = @{}
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            # Remove quotes if present
            $value = $value -replace '^["'']|["'']$'
            $envVars[$key] = $value
        }
    }
    return $envVars
}

# Get the script's directory and find the root directory (where .env files are)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir

# Prompt for environment choice
Write-Host "`nSelect environment:"
Write-Host "1) Local (.env.local)"
Write-Host "2) Remote (.env.remote)"
$choice = Read-Host "`nEnter your choice (1 or 2)"

# Set environment file based on choice
$envFile = switch ($choice) {
    "1" { 
        Write-Host "`nUsing local environment..."
        Join-Path $rootDir ".env.local"
    }
    "2" { 
        Write-Host "`nUsing remote environment..."
        Join-Path $rootDir ".env.remote"
    }
    default {
        Write-Error "Invalid choice. Please enter 1 or 2"
        exit 1
    }
}

# Check if the chosen env file exists
if (!(Test-Path $envFile)) {
    Write-Error "Environment file not found: $envFile"
    Write-Host "Please make sure to copy and configure the appropriate .env file:"
    Write-Host "- For local: Copy .env.local.example to .env.local"
    Write-Host "- For remote: Copy .env.remote.example to .env.remote"
    exit 1
}

$env = Get-EnvVariables $envFile

# Use environment variables
$projectUrl = $env['VITE_SUPABASE_URL']
$apiKey = $env['VITE_SUPABASE_ANON_KEY']
$graphqlEndpoint = $env['VITE_GRAPHQL_ENDPOINT']

if (!$projectUrl -or !$apiKey) {
    Write-Error "Missing required environment variables in $envFile"
    Write-Host "Please ensure VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY are set"
    exit 1
}

# Define the GraphQL query
$query = @"
{
  pingsCollection {
    edges {
      node {
        id
        created_at
      }
    }
  }
}
"@

# Construct the request body
$requestBody = @{
    query = $query
} | ConvertTo-Json

Write-Host "`nQuerying pings from: $projectUrl"


# Make the HTTP request
$response = Invoke-RestMethod -Uri $graphqlEndpoint -Method Post -Headers @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
} -Body $requestBody

# Output the response
$response | ConvertTo-Json -Depth 10
