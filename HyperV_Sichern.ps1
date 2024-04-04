<#
.SYNOPSIS
Backup-Skript für Hyper-V VMs, das die VMs je nach Konfiguration live exportiert, bei laufendem Betrieb überspringt oder herunterfährt, exportiert und wieder hochfährt.

.DESCRIPTION
Dieses Skript führt ein Backup von Hyper-V VMs durch, wobei der Backup-Prozess basierend auf den übergebenen Parametern konfiguriert wird. Es unterstützt Live-Export, Überspringen laufender VMs oder Herunterfahren der VMs vor dem Export.

.PARAMETER BackupPath
Der Netzwerkpfad, an dem die VMs gesichert werden sollen. Standard ist "\\192.168.0.185\Backup\HyperV".

.PARAMETER TmpExport
Das temporäre lokale Verzeichnis für den Export. Standard ist "f:\Backup".

.PARAMETER ExportType
Der Exporttyp. Mögliche Werte sind 1 für Live-Export, 2 für Überspringen, wenn VM läuft, und 3 für Herunterfahren, Exportieren, Hochfahren. Standard ist 2.

.EXAMPLE
PS> .\VMBackup.ps1 -BackupPath "\\192.168.0.200\Backup\HyperV" -TmpExport "c:\TempBackup" -ExportType 1

.AUTHOR
Erhard Rainer
http://erhard-rainer.com

.VERSIONHISTORY
1.0 - Initial Version

.NOTES
Lizenz: Creative Commons Attribution 4.0 International License (CC BY 4.0)
#>

param(
    [string]$BackupPath = "\\192.168.0.185\Backup\HyperV",
    [string]$TmpExport = "f:\Backup",
    [int]$ExportType = 2
)

# Stellen Sie sicher, dass das finale und temporäre Verzeichnis existiert
if (-not (Test-Path $BackupPath)) {
    Write-Error "Das finale Backup-Verzeichnis '$BackupPath' existiert nicht."
    exit
}
if (-not (Test-Path $TmpExport)) {
    New-Item -Path $TmpExport -ItemType Directory
}

# Alle VMs abrufen
$vms = Get-VM

foreach ($vm in $vms) {
    # Überprüfen, ob die VM gerade exportiert wird
    if ($vm.OperationalStatus -contains "ExportingVirtualMachine") {
        Write-Host "VM $($vm.Name) wird gerade exportiert und kann nicht gesichert werden."
        continue
    }

    $vmRunning = $vm.State -eq 'Running' # Überprüfen, ob die VM läuft
    $vhds = Get-VMHardDiskDrive -VMName $vm.Name # Datum der letzten Änderung an den VHDs/VHDXs ermitteln
    $latestVHDChangeDate = ($vhds | ForEach-Object {
        (Get-Item $_.Path).LastWriteTime
    } | Measure-Object -Maximum).Maximum

    # Prüfen, ob ein Backup-Verzeichnis für die VM existiert
    $lastExportPath = Get-ChildItem -Path $BackupPath -Directory | Where-Object { $_.Name -match "^$($vm.Name)_" } | Sort-Object CreationTime -Descending | Select-Object -First 1
    $lastExportDate = if ($lastExportPath) { $lastExportPath.CreationTime } else { [datetime]::MinValue }

    if ($latestVHDChangeDate -le $lastExportDate) {
        Write-Host "VM $($vm.Name) hat keine neuen Änderungen seit dem letzten Backup. Überspringe Export."
        continue
    }

    $vmTmpExportPath = Join-Path -Path $TmpExport -ChildPath $vm.Name # Temporäres Exportverzeichnis

    # Exportieren der VM
    Export-VM -VM $vm -Path $vmTmpExportPath
    Write-Host "Exportiere VM: $($vm.Name) nach $vmTmpExportPath"

    # Kopieren der exportierten VM
    $vmFinalExportPath = Join-Path -Path $BackupPath -ChildPath $vm.Name
    Copy-Item -Path $vmTmpExportPath -Destination $vmFinalExportPath -Recurse -Force
    Write-Host "Kopiere exportierte VM nach $BackupPath"

    # Größenvergleich und Bereinigung
    $tempSize = (Get-ChildItem -Path $vmTmpExportPath -Recurse | Measure-Object -Property Length -Sum).Sum
    $finalSize = (Get-ChildItem -Path $vmFinalExportPath -Recurse | Measure-Object -Property Length -Sum).Sum
    if ($tempSize -eq $finalSize) {
        Write-Host "Überprüfung erfolgreich: Die Größe der Dateien stimmt überein. Bereinigung wird durchgeführt."
        Remove-Item -Path $vmTmpExportPath -Recurse -Force
    } else {
        Write-Host "Warnung: Die Größe der Dateien stimmt nicht überein. Bereinigung wird nicht durchgeführt."
    }

    # VM nach dem Export neu starten, falls erforderlich
    if ($ExportType -eq 3 -and $vmRunning) {
        Start-VM -Name $vm.Name
        Write-Host "Starte VM $($vm.Name) nach dem Export neu."
    }
}

Write-Host "Backup-Prozess abgeschlossen."