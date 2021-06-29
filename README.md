# Logic app health check

This is a PowerShell script to check health for all logic apps inside a
resource group.

## How to use

You need to execute this script in Azure CloudShell. 

- Open Azure CloudShell
- Upload this script into Azure CloudShell storage account 
- Navigate to the script location and execute the below command.

```
./Check-LogicAppHealth.ps1 -ResourceGroupName "<resource-group-name>"
```