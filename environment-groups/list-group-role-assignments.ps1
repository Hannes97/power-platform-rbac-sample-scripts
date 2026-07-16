$config = & "$PSScriptRoot\..\config.ps1"

# Authenticate and obtain an access token
Connect-AzAccount
$secureToken = (Get-AzAccessToken -TenantId $config.TenantId -ResourceUrl "https://api.powerplatform.com/").Token
$accessToken = [System.Net.NetworkCredential]::new("", $secureToken).Password

$headers = @{ 'Authorization' = 'Bearer ' + $accessToken }
$headers.Add('Content-Type', 'application/json')

$roleAssignments = Invoke-RestMethod -Method Get -Uri "https://api.powerplatform.com/authorization/environmentGroups/$($config.EnvironmentGroupId)/roleAssignments?api-version=2024-10-01" -Headers $headers

# Display the role assignments
$roleAssignments | ConvertTo-Json | Write-Host

# Filter for the service principal's assignments
Write-Host "`nFiltered for service principal:"
$roleAssignments.value | Where-Object { $_.principalObjectId -eq $config.EnterpriseAppObjectId } | Format-Table roleAssignmentId, roleDefinitionId, scope, principalType
