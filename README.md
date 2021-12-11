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

Output:

```
----  DemoLogicAppName  (start time, end time, status)
6/28/2021 10:26:49 AM   6/28/2021 10:26:49 AM   Succeeded
6/28/2021 10:16:49 AM   6/28/2021 10:16:49 AM   Succeeded
6/28/2021 10:06:48 AM   6/28/2021 10:06:49 AM   Succeeded
6/28/2021 9:56:48 AM   6/28/2021 9:56:48 AM   Succeeded
6/28/2021 9:46:48 AM   6/28/2021 9:46:55 AM   Succeeded
6/28/2021 9:36:47 AM   6/28/2021 9:36:48 AM   Succeeded
6/28/2021 9:26:47 AM   6/28/2021 9:26:47 AM   Succeeded
6/28/2021 9:16:47 AM   6/28/2021 9:16:47 AM   Succeeded
6/28/2021 9:06:46 AM   6/28/2021 9:06:47 AM   Succeeded
6/28/2021 8:56:46 AM   6/28/2021 8:56:46 AM   Succeeded
```

> :point_right: Note: If you find an error saying **script has parse errors** or **`Workflow` type is not found** 
> then check [this issue](https://github.com/Arnab-Developer/LogicAppHealthCheck/issues/1).
