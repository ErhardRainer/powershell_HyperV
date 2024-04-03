# Pfad, an dem die VMs gesichert werden sollen
$BackupPath = "\\192.168.0.185\Backup\HyperV"
# Temporäres lokales Verzeichnis für den Export
$tmpExport = "f:\Backup"
# Exporttyp definieren: 1 = Live-Export, 2 = Überspringen wenn läuft, 3 = Herunterfahren, Exportieren, Hochfahren
$exportType = 2

# Stellen Sie sicher, dass das finale und temporäre Verzeichnis existiert
if (-not (Test-Path $BackupPath)) {
    Write-Error "Das finale Backup-Verzeichnis '$BackupPath' existiert nicht."
    exit
}
if (-not (Test-Path $tmpExport)) {
    New-Item -Path $tmpExport -ItemType Directory
}

# Alle VMs abrufen
$vms = Get-VM

foreach ($vm in $vms) {
    # Überprüfen, ob die VM gerade exportiert wird
    if ($vm.OperationalStatus -contains "ExportingVirtualMachine") {
        Write-Host "VM $($vm.Name) wird gerade exportiert und kann nicht gesichert werden."
        continue
    }

    # Überprüfen, ob die VM läuft
    $vmRunning = $vm.State -eq 'Running'

    # Datum der letzten Änderung an den VHDs/VHDXs ermitteln
    $vhds = Get-VMHardDiskDrive -VMName $vm.Name
    $latestVHDChangeDate = ($vhds | ForEach-Object {
        if (Test-Path $_.Path) {
            (Get-Item $_.Path).LastWriteTime
        } else {
            [datetime]::MinValue
        }
    } | Measure-Object -Maximum).Maximum

    # Prüfen, ob ein Backup-Verzeichnis für die VM existiert und das Datum des letzten Exports ermitteln
    $lastExportPath = Get-ChildItem -Path $BackupPath -Directory | Where-Object { $_.Name -match "^$($vm.Name)_" } | Sort-Object CreationTime -Descending | Select-Object -First 1
    if ($lastExportPath) {
        $lastExportDate = $lastExportPath.CreationTime
    } else {
        $lastExportDate = [datetime]::MinValue
    }

    # Prüfen, ob das Datum der letzten Änderung neuer ist als das Datum des letzten Exports
    if ($latestVHDChangeDate -le $lastExportDate) {
        Write-Host "VM $($vm.Name) hat keine neuen Änderungen seit dem letzten Backup. Überspringe Export."
        continue
    }

    # Temporäres Exportverzeichnis für diese spezielle VM
    $vmTmpExportPath = Join-Path -Path $tmpExport -ChildPath $vm.Name

    # Exportieren der VM ins temporäre Verzeichnis
    Write-Host "Exportiere VM: $($vm.Name) nach $vmTmpExportPath"
    Export-VM -VM $vm -Path $vmTmpExportPath

    # Kopieren der exportierten VM zum endgültigen Netzwerkshare
    Write-Host "Kopiere exportierte VM nach $BackupPath"
    $vmFinalExportPath = Join-Path -Path $BackupPath -ChildPath $vm.Name
    Copy-Item -Path $vmTmpExportPath -Destination $vmFinalExportPath -Recurse -Force

    # Größe der Dateien im temporären Verzeichnis berechnen
    $tempSize = (Get-ChildItem -Path $vmTmpExportPath -Recurse | Measure-Object -Property Length -Sum).Sum

    # Größe der Dateien im finalen Verzeichnis berechnen
    $finalSize = (Get-ChildItem -Path $vmFinalExportPath -Recurse | Measure-Object -Property Length -Sum).Sum

    # Überprüfen, ob die Größen übereinstimmen
    if ($tempSize -eq $finalSize) {
        Write-Host "Überprüfung erfolgreich: Die Größe der Dateien stimmt überein. Bereinigung wird durchgeführt."
        # Aufräumen des temporären Verzeichnisses
        Remove-Item -Path $vmTmpExportPath -Recurse -Force
    } else {
        Write-Host "Warnung: Die Größe der Dateien im temporären Verzeichnis und im finalen Verzeichnis stimmt nicht überein. Bereinigung wird nicht durchgeführt."
    }

    # VM nach dem Export neu starten, falls erforderlich
    if ($exportType -eq 3 -and $vmRunning) {
        Write-Host "Starte VM $($vm.Name) nach dem Export neu."
        Start-VM -Name $vm.Name
    }
}

Write-Host "Backup-Prozess abgeschlossen."