# Power Platform RBAC Sample Scripts

Sample PowerShell scripts for managing [Power Platform role-based access control (RBAC)](https://learn.microsoft.com/en-us/power-platform/admin/security/role-based-access-control) via the [Power Platform Authorization API](https://learn.microsoft.com/en-us/rest/api/power-platform/authorization/role-based-access-control).

### Built-in Power Platform roles

Roles can't be customized. The four built-in roles and their role definition IDs are:

| Role name                                                | Role definition ID                     | Permissions                                                                 |
| -------------------------------------------------------- | -------------------------------------- | --------------------------------------------------------------------------- |
| Power Platform owner                                     | `0cb07c69-1631-4725-ab35-e59e001c51ea` | All permissions.                                                            |
| Power Platform contributor                               | `ff954d61-a89a-4fbe-ace9-01c367b89f87` | Manage and read all resources, but can't make or change role assignments.  |
| Power Platform reader                                    | `c886ad2e-27f7-4874-8381-5849b8d8a090` | Read-only access to all resources.                                         |
| Power Platform role-based access control administrator   | `95e94555-018c-447b-8691-bdac8e12211e` | Read all resources plus manage role assignments.                           |

The assignment scripts default to **Power Platform contributor**. To use a different role, change the `$roleDefinitionId` variable. See the [built-in roles reference](https://learn.microsoft.com/en-us/power-platform/admin/security/role-based-access-control#built-in-power-platform-roles) for details.

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- The [Az.Accounts PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell) (`Connect-AzAccount`, `Get-AzAccessToken`).
- An **admin identity** that holds the **Power Platform Administrator** or **Power Platform role-based access control administrator** role.

The app-only service principal used by `assign-role-to-all-group-environments.ps1` requires an app registration with the appropriate Power Platform API *application* permissions (admin-consented) that is also registered as a Power Platform management application. See the header comments in [`auth.ps1`](auth.ps1) and the [Authentication guide](https://learn.microsoft.com/en-us/power-platform/admin/programmability-authentication-v2) for setup details.

## Configuration

The scripts read their settings from a `config.ps1` file in the repository root. This file is git-ignored so your tenant-specific values are never committed.

1. Copy the sample:

   ```powershell
   Copy-Item config.sample.ps1 config.ps1
   ```

2. Edit `config.ps1` and fill in your values:

   | Key                     | Description                                                                                              |
   | ----------------------- | -------------------------------------------------------------------------------------------------------- |
   | `TenantId`              | Microsoft Entra (Azure AD) tenant ID.                                                       |
   | `EnterpriseAppObjectId` | Enterprise application object ID of the service principal / managed identity to assign a role to.        |
   | `EntraUserObjectId`     | Object ID of the Microsoft Entra user to assign a role to (if desired).                                               |
   | `EnvironmentGroupId`    | ID of the Power Platform environment group to target.                                                   |
   | `ClientId`              | App registration client ID (used by the app-only service principal in `auth.ps1`).                      |
   | `ClientSecret`          | App registration client secret (used by the app-only service principal in `auth.ps1`).                  |

## Scripts

All scripts live under `environment-groups/` and are run from the repository root. They target Power Platform API version `2024-10-01`.

### List role assignments

```powershell
./environment-groups/list-group-role-assignments.ps1
```

Prints the current role assignments on the configured environment group as JSON, then filters for the service principal's assignments. Authenticates interactively via `Connect-AzAccount`.

### Assign a role to a service principal

```powershell
./environment-groups/assign-group-role-to-service-principal.ps1
```

Assigns the **Power Platform contributor** role to the `EnterpriseAppObjectId` principal (`principalType = ApplicationUser`) on the configured environment group. If the assignment already exists, the script reports it and exits cleanly. Authenticates interactively via `Connect-AzAccount`.

### Assign a role to a user

```powershell
./environment-groups/assign-group-role-to-user.ps1
```

Assigns the **Power Platform contributor** role to the `EntraUserObjectId` user (`principalType = User`) on the configured environment group. If the assignment already exists, the script reports it and exits cleanly. Authenticates interactively via `Connect-AzAccount`.

### Assign a role to every environment in a group

```powershell
./environment-groups/assign-role-to-all-group-environments.ps1
```

Enumerates every environment inside the configured environment group and assigns the **Power Platform contributor** role to the `EnterpriseAppObjectId` principal at each **environment** scope (rather than at the group scope). Runs in dry-run mode by default; set `$DryRun = $false` in the script to create the assignments.

This script uses two identities: the app-only service principal (via `auth.ps1`) reads the environments in the group, and an interactive admin user (`Connect-AzAccount`) reads and creates the role assignments.

## Notes

- The scripts call `Connect-AzAccount` to obtain an interactive admin access token for `https://api.powerplatform.com/`. `assign-role-to-all-group-environments.ps1` additionally uses the client credentials flow in `auth.ps1` to read the group's environments with the service principal.
- To use a different role, change the `$roleDefinitionId` variable in the relevant script. See the [built-in Power Platform roles](https://learn.microsoft.com/en-us/power-platform/admin/security/role-based-access-control#built-in-power-platform-roles).

## References

- [Role-based access control for Power Platform admin center](https://learn.microsoft.com/en-us/power-platform/admin/security/role-based-access-control)
- [Tutorial: Assign roles to service principals](https://learn.microsoft.com/en-us/power-platform/admin/programmability-tutorial-rbac-role-assignment?tabs=PowerShell)
- [Power Platform API reference — Authorization](https://learn.microsoft.com/en-us/rest/api/power-platform/authorization/role-based-access-control)
