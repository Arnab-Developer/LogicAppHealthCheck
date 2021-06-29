using namespace Microsoft.Azure.Management.Logic.Models
using namespace System.Collections.Generic

param([string] $ResourceGroupName) 

class LogicAppModel
{
    [string] $RgName
    [string] $LogicAppName
    [IEnumerable[LogicAppRunHistoryModel]] $RunHistory
}

class LogicAppRunHistoryModel
{
    [DateTime] $StartTime
    [DateTime] $EndTime
    [string] $Status
}

class LogicAppRepo 
{
    [string] $RgName

    [IEnumerable[LogicAppModel]] GetByResourceGroup() 
    {
        [IEnumerable[Workflow]] $logicApps = Get-AzLogicApp -ResourceGroupName $this.RgName
        [IEnumerable[LogicAppModel]] $logicAppModels = [List[LogicAppModel]]::new()
        foreach ($logicApp in $logicApps)
        {
            $logicAppModel = [LogicAppModel]::new()
            $logicAppModel.RgName = $this.RgName
            $logicAppModel.LogicAppName = $logicApp.Name

            $logicAppModels.Add($logicAppModel)
        }
        return $logicAppModels
    }

    [IEnumerable[LogicAppRunHistoryModel]] GetRunHistoryByName([string] $logicAppName) 
    {
        [WorkflowRun[]] $workflowRuns = Get-AzLogicAppRunHistory -ResourceGroupName $this.RgName `
            -Name $logicAppName | Sort-Object -Property StartTime -Descending | Select-Object -First 10
            
        [IEnumerable[LogicAppRunHistoryModel]] $logicAppRunHistoryModels `
            = [List[LogicAppRunHistoryModel]]::new() 

        foreach ($workflowRun in $workflowRuns)
        {
            $logicAppRunHistoryModel = [LogicAppRunHistoryModel]::new()
            $logicAppRunHistoryModel.StartTime = $workflowRun.StartTime
            if ($workflowRun.EndTime -ne $null) 
            {
                $logicAppRunHistoryModel.EndTime = $workflowRun.EndTime
            }
            $logicAppRunHistoryModel.Status = $workflowRun.Status

            $logicAppRunHistoryModels.Add($logicAppRunHistoryModel)
        }

        return $logicAppRunHistoryModels
    }
}

function PopulateRunHistory([IEnumerable[LogicAppModel]] $logicAppModels)
{
    foreach ($logicAppModel in $logicAppModels)
    {
        [IEnumerable[LogicAppRunHistoryModel]] $logicAppRunHistoryModels `
            = $logicAppRepo.GetRunHistoryByName($logicAppModel.LogicAppName)

        $logicAppModel.RunHistory = $logicAppRunHistoryModels
    }
}

function PrintResult([IEnumerable[LogicAppModel]] $logicAppModels)
{
    foreach ($logicAppModel in $logicAppModels)
    {
        Write-Host "----" $logicAppModel.LogicAppName " (start time, end time, status)"
        foreach ($runHistory in $logicAppModel.RunHistory)
        {
            Write-Host $runHistory.StartTime " " $runHistory.EndTime " " $runHistory.Status
        }
        Write-Host ""
    }
}

$logicAppRepo = [LogicAppRepo]::new()
$logicAppRepo.RgName = $ResourceGroupName

[IEnumerable[LogicAppModel]] $logicAppModels = $logicAppRepo.GetByResourceGroup()
PopulateRunHistory($logicAppModels)

PrintResult($logicAppModels)

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