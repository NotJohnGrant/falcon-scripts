Requires -Version 5.1 -Modules @{ModuleName="PSFalcon";ModuleVersion='2.1'}


try {
    $hostList = Get-FalconHost -Filter "tags:['SensorGroupingTags/VDI-NP']" -Detailed -All

    $uniqueSerials = $hostList | Group-Object -Property serial_number | Select-Object -ExpandProperty Name
    $duplicateHosts = @()
    foreach ($x in $uniqueSerials){
        $workingSet = $hostList | Where-Object{$_.serial_number -eq $x}
        for ($i = 0; $i -lt $workingSet.count; $i++){
            if ($i -eq 0){
                $latestHost = $workingSet[$i]
            } else {
                $latestHostDate = Get-Date -Date $latestHost.last_seen
                $newHostDate = Get-Date -Date $workingSet[$i].last_seen
                if ($latestHostDate -gt $newHostDate ){
                    $duplicateHosts += $workingSet[$i].device_id
                } else {
                    $duplicateHosts += $latestHost
                    $latestHost = $workingSet[$i]
                }
            }
            
        }
    
    }   
    
    Invoke-FalconHostAction -Name hide_host -Ids $duplicateHosts.device_id
}
catch {
    WRite-Error $_
}


