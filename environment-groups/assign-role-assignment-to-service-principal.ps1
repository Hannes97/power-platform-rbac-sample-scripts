$config = & "$PSScriptRoot\..\config.ps1"

# Authenticate and obtain an access token
Connect-AzAccount
$secureToken = (Get-AzAccessToken -TenantId $config.TenantId -ResourceUrl "https://api.powerplatform.com/").Token
$accessToken = [System.Net.NetworkCredential]::new("", $secureToken).Password

$headers = @{ 'Authorization' = 'Bearer ' + $accessToken }
$headers.Add('Content-Type', 'application/json')

# Role definition ids (https://learn.microsoft.com/en-us/power-platform/admin/security/role-based-access-control#built-in-power-platform-roles)
$roleDefinitionId = "ff954d61-a89a-4fbe-ace9-01c367b89f87" # Power Platform Contributor

$body = @{
    principalObjectId = $config.EnterpriseAppObjectId
    principalType     = "ApplicationUser"
    roleDefinitionId  = $roleDefinitionId
    scope             = "/tenants/$($config.TenantId)/environmentGroups/$($config.EnvironmentGroupId)"
} | ConvertTo-Json -Depth 5

try {
    Invoke-RestMethod -Method Post -Uri "https://api.powerplatform.com/authorization/environmentGroups/$($config.EnvironmentGroupId)/roleAssignments?api-version=2024-10-01" -Headers $headers -Body $body
}
catch {
    if ($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::Conflict) {
        Write-Host "Role assignment already exists for principal $($config.EnterpriseAppObjectId) on environment group $($config.EnvironmentGroupId) — nothing to do." -ForegroundColor Yellow
    }
    else {
        throw
    }
}
