$config = & "$PSScriptRoot\..\config.ps1"

# Set to $false to actually create assignments
$DryRun = $true

# Authenticate and obtain an access token
Connect-AzAccount
$secureToken = (Get-AzAccessToken -TenantId $config.TenantId -ResourceUrl "https://api.powerplatform.com/").Token
$accessToken = [System.Net.NetworkCredential]::new("", $secureToken).Password

$headers = @{ 'Authorization' = 'Bearer ' + $accessToken }
$headers.Add('Content-Type', 'application/json')

# Get environments in environment group
Write-Host "Reading Environment Group..." -ForegroundColor Cyan
 
$environmentsResponse = Invoke-RestMethod -Method GET -Uri "https://api.powerplatform.com/environmentGroups/$($config.EnvironmentGroupId)/environments?api-version=2024-10-01" -Headers $headers
$environments = $environmentsResponse.value

Write-Host "Found $($environments.Count) environments"

# Assign role

foreach ($env in $environments) {
    Write-Host ""
    Write-Host "Processing: $($env.displayName)" -ForegroundColor Yellow

    $environmentId = $env.id

    $assignmentUri = "https://api.powerplatform.com/authorization/environments/$environmentId/roleAssignments?api-version=2024-10-01"

    $existingAssignments = Invoke-RestMethod -Method GET -Uri $assignmentUri -Headers $headers

    $existing = $existingAssignments.value | Where-Object { $_.principalObjectId -eq $config.EnterpriseAppObjectId -and $_.roleDefinitionId -eq $RoleDefinitionId }

    if ($existing) {
        Write-Host "Already assigned" -ForegroundColor Green
        continue
    }

    $body = @{
        principalObjectId = $config.EnterpriseAppObjectId
        principalType     = "ApplicationUser"
        roleDefinitionId  = $RoleDefinitionId
        scope             = "/environments/$environmentId"
    } | ConvertTo-Json

    if ($DryRun) {
        Write-Host "DRYRUN: would assign Contributor role" -ForegroundColor Magenta
    } else {
        Invoke-RestMethod -Method POST -Uri $assignmentUri -Headers $headers -Body $body
        Write-Host "Assignment created" -ForegroundColor Green
    }
}

Write-Host ""

Write-Host "Completed."
