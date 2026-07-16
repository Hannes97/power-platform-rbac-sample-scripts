# Acquires an app-only (client credentials) access token for the Power Platform API
# and returns ready-to-use request headers.
#
# Requirements:
#   1. The app registration (config.ClientId) must have the required Power Platform API
#      *application* permissions granted with admin consent, e.g.:
#        - AppManagement.ApplicationPackages.Install
#        - EnvironmentManagement.Environments.Read (and related EnvironmentManagement.* scopes)
#        - Licensing.Allocations.Read
#      In the Azure portal: App registration > API permissions > Add a permission >
#      APIs my organization uses > "Power Platform API" > Application permissions.
#   2. The service principal must be registered as a Power Platform management application:
#        Add-PowerAppsAccount
#        New-PowerAppManagementApp -ApplicationId <config.ClientId>
#      (from the Microsoft.PowerApps.Administration.PowerShell module).
#
# Usage:
#   $config  = & "$PSScriptRoot\..\config.ps1"
#   $headers = & "$PSScriptRoot\..\auth.ps1" $config

param(
    [Parameter(Mandatory = $true)]
    [hashtable]$config
)

$tokenBody = @{
    grant_type    = 'client_credentials'
    client_id     = $config.ClientId
    client_secret = $config.ClientSecret
    scope         = 'https://api.powerplatform.com/.default'
}

$tokenResponse = Invoke-RestMethod -Method Post `
    -Uri "https://login.microsoftonline.com/$($config.TenantId)/oauth2/v2.0/token" `
    -ContentType 'application/x-www-form-urlencoded' `
    -Body $tokenBody

@{
    'Authorization' = "Bearer $($tokenResponse.access_token)"
    'Content-Type'  = 'application/json'
}
