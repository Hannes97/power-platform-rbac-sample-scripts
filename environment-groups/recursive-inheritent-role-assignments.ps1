$config = & "$PSScriptRoot\..\config.ps1"

# Set to $false to actually create assignments
$DryRun = $true

# Authenticate (app-only) and obtain request headers
$headers = & "$PSScriptRoot\..\auth.ps1" $config

# List of role definition ids: https://learn.microsoft.com/en-us/power-platform/admin/security/role-based-access-control#built-in-power-platform-roles
$roleDefinitionId = "ff954d61-a89a-4fbe-ace9-01c367b89f87" # Power Platform Contributor

# Get environments in environment group
Write-Host "Reading Environment Group..." -ForegroundColor Cyan
 
$environmentsResponse = Invoke-RestMethod -Method GET -Uri "https://api.powerplatform.com/environmentmanagement/environments?`$filter=environmentGroupId%20eq%20'$($config.EnvironmentGroupId)'&api-version=2024-10-01" -Headers $headers
$environments = $environmentsResponse.value

Write-Host "Found $($environments.Count) environments"

# Assign role

foreach ($env in $environments) {
    Write-Host ""
    Write-Host "Processing: $($env.displayName)" -ForegroundColor Yellow

    $environmentId = $env.id

    $assignmentUri = "https://api.powerplatform.com/authorization/environments/$environmentId/roleAssignments?api-version=2024-10-01"

    $existingAssignments = Invoke-RestMethod -Method GET -Uri $assignmentUri -Headers $headers

    $existing = $existingAssignments.value | Where-Object { $_.principalObjectId -eq $config.EnterpriseAppObjectId -and $_.roleDefinitionId -eq $roleDefinitionId }

    if ($existing) {
        Write-Host "Already assigned" -ForegroundColor Green
        continue
    }

    $body = @{
        principalObjectId = $config.EnterpriseAppObjectId
        principalType     = "ApplicationUser"
        roleDefinitionId  = $roleDefinitionId
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
