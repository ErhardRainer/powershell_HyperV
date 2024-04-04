# PowerShell-Skript zur Duplizierung einer Hyper-V VM und Anwendung eines Snapshots

# Namen und Pfade definieren
$originalVmName = "Original_VM_Name" # Name der Original-VM
$exportPath = "C:\Pfad_für_Export"   # Pfad, an dem die VM exportiert werden soll
$copiedVmName = "Kopierte_VM_Name"   # Name der kopierten VM
$snapshotName = "Dein_Snapshot_Name" # Name des anzuwendenden Snapshots

# Schritt 1: Exportieren der Original-VM
Write-Host "Exportiere Original-VM..."
Export-VM -Name $originalVmName -Path $exportPath

# Schritt 2: Importieren und Erstellen einer Kopie der VM
Write-Host "Importiere und erstelle Kopie der VM..."
Import-VM -Path "$exportPath\$originalVmName" -Copy -NewName $copiedVmName

# Schritt 3: Identifizieren des Snapshots
Write-Host "Identifiziere Snapshot..."
$snapshot = Get-VM -Name $copiedVmName | Get-VMSnapshot -Name $snapshotName

# Schritt 4: Anwenden des Snapshots auf die kopierte VM
Write-Host "Wende Snapshot auf kopierte VM an..."
Apply-VMSnapshot -Snapshot $snapshot

Write-Host "Skript abgeschlossen."