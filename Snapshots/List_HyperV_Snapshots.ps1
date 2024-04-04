$vmName = "Deine_VM_Name"
$snapshots = Get-VM -Name $vmName | Get-VMSnapshot
$snapshots | Format-Table -Property VMName, Name, CreationTime, State