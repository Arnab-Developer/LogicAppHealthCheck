# Logic app health check

This is a PowerShell script to check health for all logic apps inside a
resource group.

Install from PowerShell Gallery.

```
Install-Script -Name Check-LogicAppHealth
```

Run the below command to run the script.

```
Check-LogicAppHealth.ps1 -ResourceGroupName "<resource-group-name>"
```