$snapshotName = "Dein_Snapshot_Name"
$vmName = "Deine_VM_Name"
$snapshot = Get-VM -Name $vmName | Get-VMSnapshot -Name $snapshotName
Apply-VMSnapshot -VM $snapshot