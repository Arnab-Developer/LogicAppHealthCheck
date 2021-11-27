using namespace Microsoft.Azure.Management.Logic.Models
using namespace System.Collections.Generic

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] 
    $ResourceGroupName
)

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
    hidden [string] $RgName

    LogicAppRepo([string] $rgName)    
    {
        $this.RgName = $rgName
    }

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

$logicAppRepo = [LogicAppRepo]::new($ResourceGroupName)
[IEnumerable[LogicAppModel]] $logicAppModels = $logicAppRepo.GetByResourceGroup()
PopulateRunHistory($logicAppModels)
PrintResult($logicAppModels)