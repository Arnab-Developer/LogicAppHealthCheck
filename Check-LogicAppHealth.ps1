using namespace Microsoft.Azure.Management.Logic.Models
using namespace System.Collections.Generic

param([string] $ResourceGroupName) 

class LogicAppRepo 
{
    [string] $RgName

    [IEnumerable[Workflow]] GetNamesByResourceGroup() 
    {       
        return Get-AzLogicApp -ResourceGroupName $this.RgName
    }

    [IEnumerable[LogicAppHealthCheckResult]] GetRunHistoryByName([string] $LogicAppName) 
    {       
        [WorkflowRun[]] $WorkflowRuns = Get-AzLogicAppRunHistory -ResourceGroupName $this.RgName `
            -Name $LogicAppName | Sort-Object -Property StartTime -Descending | Select-Object -First 10
            
        [IEnumerable[LogicAppHealthCheckResult]] $LogicAppHealthCheckResults `
            = [List[LogicAppHealthCheckResult]]::new()

        foreach($WorkflowRun in $WorkflowRuns) 
        {
            $LogicAppHealthCheckResult = [LogicAppHealthCheckResult]::new()
            $LogicAppHealthCheckResult.StartTime = $WorkflowRun.StartTime
            $LogicAppHealthCheckResult.EndTime = $WorkflowRun.EndTime
            $LogicAppHealthCheckResult.Status = $WorkflowRun.Status

            $LogicAppHealthCheckResults.Add($LogicAppHealthCheckResult)
        }
        return $LogicAppHealthCheckResults
    }
}

class LogicAppHealthCheck 
{    
    [string] $RgName    
}

class LogicAppHealthCheckResult 
{
    [DateTime] $StartTime
    [DateTime] $EndTime
    [string] $Status
}

$LogicAppRepo = [LogicAppRepo]::new()
$LogicAppRepo.RgName = $ResourceGroupName
[IEnumerable[Workflow]] $LogicApps = $LogicAppRepo.GetNamesByResourceGroup()

$LogicAppHealthCheck = [LogicAppHealthCheck]::new()
$LogicAppHealthCheck.RgName = $ResourceGroupName

foreach($LogicApp in $LogicApps) 
{
    Write-Host "---- " $LogicApp.Name " (start time, end time, status)"

    [IEnumerable[LogicAppHealthCheckResult]] $LogicAppHealthCheckResults `
        = $LogicAppRepo.GetRunHistoryByName($LogicApp.Name)

    foreach($LogicAppHealthCheckResult in $LogicAppHealthCheckResults) 
    {
       Write-Host $LogicAppHealthCheckResult.StartTime " " $LogicAppHealthCheckResult.EndTime `
           " " $LogicAppHealthCheckResult.Status
    }
    Write-Host ""
}

<#
Output:

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
#>