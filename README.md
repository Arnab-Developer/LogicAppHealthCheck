# Logic app health check

This is a PowerShell script to check health of all logic apps inside a
resource group.

Install from PowerShell Gallery.

```
Install-Script -Name Check-LogicAppHealth
```

Run the below command to run the script[^note].

```
Check-LogicAppHealth.ps1 -ResourceGroupName "<resource-group-name>"
```

[^note]:
    If you find an error saying **`Workflow` type is not found** then check 
    [this issue](https://github.com/Arnab-Developer/LogicAppHealthCheck/issues/1)
