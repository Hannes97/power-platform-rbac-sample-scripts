$config = & "$PSScriptRoot\..\config.ps1"

# Authenticate (app-only) and obtain request headers
$headers = & "$PSScriptRoot\..\auth.ps1" $config

$roleAssignments = Invoke-RestMethod -Method Get -Uri "https://api.powerplatform.com/authorization/environmentGroups/$($config.EnvironmentGroupId)/roleAssignments?api-version=2024-10-01" -Headers $headers

# Display the role assignments
$roleAssignments | ConvertTo-Json | Write-Host
