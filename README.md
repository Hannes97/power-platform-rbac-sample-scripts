# power-platform-rbac-sample-scripts

Sample PowerShell scripts for managing [Power Platform role-based access control (RBAC)](https://learn.microsoft.com/en-us/power-platform/admin/security/role-based-access-control) on environment groups via the Power Platform API.

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- The [Az PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell) (`Connect-AzAccount`, `Get-AzAccessToken`)
- An account with permission to manage role assignments on the target environment group

## Configuration

The scripts read their settings from a `config.ps1` file in the repository root. This file is git-ignored so your tenant-specific values are never committed.

1. Copy the sample:

   ```powershell
   Copy-Item config.sample.ps1 config.ps1
   ```

2. Edit `config.ps1` and fill in your values:

   | Key                     | Description                                                                 |
   | ----------------------- | --------------------------------------------------------------------------- |
   | `TenantId`              | Azure AD tenant (directory) ID.                                             |
   | `EnterpriseAppObjectId` | Object ID of the enterprise app / service principal to assign a role to.    |
   | `EntraUserObjectId`     | Object ID of the Entra user to assign a role to.                            |
   | `EnvironmentGroupId`    | ID of the Power Platform environment group to target.                       |
   | `ClientId`              | App registration client ID (if using client credentials auth).             |
   | `ClientSecret`          | App registration client secret (if using client credentials auth).         |

## Scripts

All scripts live under `environment-groups/` and are run from the repository root.

### List role assignments

```powershell
./environment-groups/list-role-assignments.ps1
```

Prints the current role assignments on the configured environment group as JSON.

### Assign a role to a service principal

```powershell
./environment-groups/assign-role-assignment-to-service-principal.ps1
```

Assigns the **Power Platform Contributor** role to the `EnterpriseAppObjectId` principal on the configured environment group. If the assignment already exists, the script reports it and exits cleanly.

### Assign a role to a user

```powershell
./environment-groups/assign-role-assignment-to-user.ps1
```

Assigns the **Power Platform Contributor** role to the `EntraUserObjectId` user on the configured environment group. If the assignment already exists, the script reports it and exits cleanly.

## Notes

- Each script calls `Connect-AzAccount` interactively to obtain an access token for `https://api.powerplatform.com/`.
- To use a different role, change the `$roleDefinitionId` variable in the assignment scripts. See the [built-in Power Platform roles](https://learn.microsoft.com/en-us/power-platform/admin/security/role-based-access-control#built-in-power-platform-roles) for available role definition IDs.
- The scripts target API version `2024-10-01`.
