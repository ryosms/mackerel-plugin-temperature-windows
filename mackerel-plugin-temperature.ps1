function GraphDefinition() {
    $meta = @{
        graphs = @{
            "cpu.temperature.#" = @{
                label = "CPU Temperature"
                unit = "float"
                metrics = @(@{
                    name = "celsius"
                    label = "celsius"
                    stacked = $false
                })
            }
        }
    }
    Write-Output "# mackerel-agent-plugin"
    Write-Output $($meta | ConvertTo-Json -Depth 4 -Compress)
}

function GetEpoch($date) {
    return [Math]::Truncate(($date - (Get-Date("1970/01/01 00:00:00 GMT"))).TotalSeconds)
}
function FetchMetrics() {
    $epoch = $(GetEpoch(Get-Date))

    $temperatures = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi"
    foreach($temperature in $temperatures) {
        $instanceName = $temperature.InstanceName
        $index = $instanceName.lastIndexOf("\")
        if($index -igt 0) {
            $instanceName = $instanceName.SubString($index + 1)
        }
        $celsius = $temperature.CurrentTemperature / 10 - 273.15
        Write-Output("cpu.temperature.{0}.celsius`t{1}`t{2}" -f $instanceName, $celsius, $epoch)
    }
}

if($env:MACKEREL_AGENT_PLUGIN_META -eq "1") {
    GraphDefinition
} else {
    FetchMetrics
}


