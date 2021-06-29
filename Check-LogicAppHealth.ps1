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

    [IEnumerable[LogicAppHealthCheckResult]] GetRunHistoryByName([string] $logicAppName) 
    {       
        [WorkflowRun[]] $workflowRuns = Get-AzLogicAppRunHistory -ResourceGroupName $this.RgName `
            -Name $logicAppName | Sort-Object -Property StartTime -Descending | Select-Object -First 10
            
        [IEnumerable[LogicAppHealthCheckResult]] $logicAppHealthCheckResults `
            = [List[LogicAppHealthCheckResult]]::new()

        foreach($workflowRun in $workflowRuns) 
        {
            $logicAppHealthCheckResult = [LogicAppHealthCheckResult]::new()
            $logicAppHealthCheckResult.StartTime = $workflowRun.StartTime
            $logicAppHealthCheckResult.EndTime = $workflowRun.EndTime
            $logicAppHealthCheckResult.Status = $workflowRun.Status

            $logicAppHealthCheckResults.Add($logicAppHealthCheckResult)
        }
        return $logicAppHealthCheckResults
    }
}

class LogicAppHealthCheck 
{    
    [string] $RgName

    [LogicAppHealthCheckSummary] GetHealthCheckSummary(
        [IEnumerable[LogicAppHealthCheckResult]] $logicAppHealthCheckResults)
    {
        $logicAppHealthCheckSummary = [LogicAppHealthCheckSummary]::new()

        [int] $failedRunCount = 0
        foreach ($logicAppHealthCheckResult in $logicAppHealthCheckResults)
        {
            if ($logicAppHealthCheckResult.Status -eq "Failed")
            {
                $failedRunCount++
            }
        }

        $logicAppHealthCheckSummary.FailedRunCount = $failedRunCount

        return $logicAppHealthCheckSummary
    }
}

class LogicAppHealthCheckResult 
{
    [DateTime] $StartTime
    [DateTime] $EndTime
    [string] $Status
}

class LogicAppHealthCheckSummary 
{
    [int] $FailedRunCount
}

$logicAppRepo = [LogicAppRepo]::new()
$logicAppRepo.RgName = $ResourceGroupName
[IEnumerable[Workflow]] $logicApps = $logicAppRepo.GetNamesByResourceGroup()

$logicAppHealthCheck = [LogicAppHealthCheck]::new()
$logicAppHealthCheck.RgName = $ResourceGroupName

foreach($logicApp in $logicApps) 
{
    Write-Host "---- " $logicApp.Name " (start time, end time, status)"

    [IEnumerable[LogicAppHealthCheckResult]] $logicAppHealthCheckResults `
        = $logicAppRepo.GetRunHistoryByName($logicApp.Name)

    foreach($logicAppHealthCheckResult in $logicAppHealthCheckResults) 
    {
       Write-Host $logicAppHealthCheckResult.StartTime " " $logicAppHealthCheckResult.EndTime `
           " " $logicAppHealthCheckResult.Status
    }

    [LogicAppHealthCheckSummary] $logicAppHealthCheckSummary `
        = $logicAppHealthCheck.GetHealthCheckSummary($logicAppHealthCheckResults)

    Write-Host "Failed run count: " $logicAppHealthCheckSummary.FailedRunCount
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
Failed run count:  0
#>