#find and replace "path\to-output" with your desired path for file output
$timespan = New-TimeSpan -Minutes 1
$timer = [diagnostics.stopwatch]::startnew()
while ($timer.elapsed -lt $timespan){
$gettcpconnections = Get-NetTCPConnection | Where-Object state -ne "Bound" | Select-Object localaddress,localport,remoteaddress,remoteport,state,owningprocess, @{Name="process";Expression={(Get-Process -id $_.OwningProcess).ProcessName}} | Export-Csv c:\path\to-output\net-connect.csv -NoTypeInformation -Append
$gettcpconnections
start-sleep -seconds 3
}
