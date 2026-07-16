# Select environment group via id
$environmentGroupId = "6213389e-48a0-4e89-9519-a6b61b52fe45"

# Authenticate and obtain an access token
Connect-AzAccount
$secureToken = (Get-AzAccessToken -TenantId $secrets.TenantId -ResourceUrl "https://api.powerplatform.com/").Token
$AccessToken = [System.Net.NetworkCredential]::new("", $secureToken).Password

$headers = @{ 'Authorization' = 'Bearer ' + $AccessToken }
$headers.Add('Content-Type', 'application/json')

$roleAssignments = Invoke-RestMethod -Method Get -Uri "https://api.powerplatform.com/authorization/environmentGroups/$environmentGroupId/roleAssignments?api-version=2024-10-01" -Headers $headers

# Display the role assignments
$roleAssignments | ConvertTo-Json | Write-Host

# Filter for the service principal's assignments
#Write-Host "`nFiltered for Service Principal:"
#$roleAssignments.value | Where-Object { $_.principalObjectId -eq $EnterpriseAppObjectId } | Format-Table roleAssignmentId, roleDefinitionId, scope, principalType
