# Logic app health check

This is a PowerShell script to check health of all logic apps inside a
resource group. You need to have Azure PowerShell (AZ module) installed in your system to run this script.

Install from [PowerShell Gallery](https://www.powershellgallery.com/packages/Check-LogicAppHealth).

```
Install-Script -Name Check-LogicAppHealth
```

Login with Azure PowerShell.

```
Connect-AzAccount
```

If you have more than one subscriptions then set your proper context.

```
Set-AzContext "<subscription name>"
```

Run the below command to run the script.

```
Check-LogicAppHealth.ps1 -ResourceGroupName "<resource-group-name>"
```

> :point_right: Note: If you find an error saying **script has parse errors** or **`Workflow` type is not found** 
> then check [this issue](https://github.com/Arnab-Developer/LogicAppHealthCheck/issues/1).
