<#
.SYNOPSIS
Zusammenführen von VHDX und AVHDX Dateien in die Basis-VHDX-Datei nach Erstellung einer Sicherungskopie.

.DESCRIPTION
Dieses Skript durchläuft ein angegebenes Verzeichnis, um alle .avhdx (Differenzierungs-)
und .vhdx (virtuelle Festplatten-) Dateien basierend auf ihrer Eltern-Kind-Beziehung korrekt zusammenzuführen,
nachdem eine Sicherungskopie der Originaldateien erstellt wurde, falls gewünscht.

.PARAMETER directoryPath
Der Pfad zum Verzeichnis, das die zu zusammenführenden VHDX und AVHDX Dateien enthält.

.EXAMPLE
PS> .\MergeVHDs.ps1 -directoryPath "C:\Pfad\Zum\Verzeichnis"

Führt das Zusammenführen aller AVHDX-Dateien in ihre zugehörige Basis-VHDX-Datei durch nach Erstellung einer Sicherungskopie.

.NOTES
Autor: Erhard Rainer
Version: 1.2
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$directoryPath
)

function Create-Backup {
    $sourcePath = $directoryPath
    $destinationPath = "$directoryPath" + "_Copy"

    Write-Host "Erstelle eine Sicherungskopie des Ordners $directoryPath im übergeordneten Ordner."
    Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force
    Write-Host "Sicherungskopie wurde erstellt: $destinationPath"
}

# Funktion, um eine Bestätigung vom Benutzer für das Erstellen der Sicherungskopie zu erhalten
function Get-BackupConfirmation {
    $response = Read-Host -Prompt "Möchten Sie vor dem Zusammenführen eine Sicherungskopie erstellen? (J/N)"
    if ($response -eq 'J') {
        Create-Backup
    } else {
        Write-Host "Es wird keine Sicherungskopie erstellt."
    }
}

# Fordere eine Bestätigung für das Erstellen der Sicherungskopie an
Get-BackupConfirmation

# Sammle alle .avhdx Dateien und sortiere sie aufsteigend nach dem letzten Bearbeitungsdatum
$avhdxFiles = Get-ChildItem -Path $directoryPath -Filter "*.avhdx" |
              Sort-Object LastWriteTime

foreach ($diskFile in $avhdxFiles) {
    # Ermittle die Informationen der aktuellen AVHDX-Datei
    $vhdInfo = Get-VHD -Path $diskFile.FullName
    
    # Überprüfe, ob eine Eltern-Datei existiert
    if ($vhdInfo.ParentPath) {
        # Führe die Zusammenführung nur durch, wenn die Eltern-Datei existiert
        if (Test-Path $vhdInfo.ParentPath) {
            Merge-VHD -Path $diskFile.FullName -DestinationPath $vhdInfo.ParentPath
            Write-Host "Datei $($diskFile.Name) wurde erfolgreich in die Eltern-Datei $($vhdInfo.ParentPath) zusammengeführt."
        } else {
            Write-Host "Eltern-Datei $($vhdInfo.ParentPath) für $($diskFile.Name) wurde nicht gefunden."
        }
    }
}

Write-Host "Zusammenführungsprozess abgeschlossen."