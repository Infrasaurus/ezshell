# This script grabs free space from all domain controllers in a forest, using a .NET class to query for all DCs

# Uses .NET class to grab all AD DCs in forest and store as array in variable
$DCs = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites | ForEach-Object { $_.Servers } | Select-Object Name
# Takes the array of DCs, runs logical disk query on them, and divides the Free Space field into GB
Get-WmiObject -Class win32_logicaldisk -ComputerName $DCs.Name | Format-Table systemname,deviceid,@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}} -auto