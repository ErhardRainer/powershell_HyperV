# powershell_HyperV
Hierbei handelt es sich um eine Sammlung von Hyper-V Skripten, die den Betrieb eines Hyper-V Servers erleichtern
# Replikation / Replication
## [CheckHyperVReplications.ps1](https://github.com/ErhardRainer/powershell_HyperV/blob/main/HyperV_Check_Replication.ps1)
Näheres in diesem [Blog-Artikel](https://erhard-rainer.com/2021-12/hyper-v-replication/)
### Kurzbeschreibung
Das PowerShell-Skript `CheckHyperVReplications.ps1` dient der Überwachung und Verwaltung von Hyper-V-Replikationen auf dem lokalen Computer. Es erkennt Probleme in den Replikationen, sendet detaillierte Berichte per E-Mail und versucht, kritische Replikationszustände neu zu synchronisieren. Die Konfiguration des Skripts erfolgt über eine externe XML-Datei.
### Voraussetzungen
* Hyper-V muss auf dem lokalen System installiert sein.
* Konfigurationsdetails müssen in einer XML-Datei (`mysettings.xml`) bereitgestellt werden, einschließlich E-Mail-Einstellungen und Pfaden für Replikationslogs.
### Technische Umsetzung
Das Skript führt folgende Aktionen durch:
- Überprüfung des Zustands aller Hyper-V-Replikationen auf dem lokalen Computer.
- Generierung eines Berichts über den Replikationszustand.
- Versand des Berichts per E-Mail, falls Probleme erkannt werden.
- Versuch, kritische Replikationen automatisch neu zu synchronisieren.
### Funktionen und Parameter
- **XML-Konfigurationsdatei (`mysettings.xml`)**: Enthält notwendige Konfigurationen wie E-Mail-Einstellungen und Pfade für Replikationslogs.
- **Automatische Neusynchronisierung**: Bei Erkennung von kritischen Replikationszuständen wird versucht, diese neu zu synchronisieren.
### Beispiele
Starten des Skripts ohne spezifische Parameter (nutzt Einstellungen aus der `mysettings.xml`):
> .\CheckHyperVReplications.ps1
### Versionshistorie
- 2021-11-15 - 1.0 - Erstveröffentlichung.
- 2022-01-01 - Update: Einstellungen aus XML-Datei.
- 2022-01-01 - Update: Logging auch auf Netzwerkfreigabe für Power BI Bericht.
- 2022-12-13 - Update: Starten der Neusynchronisierung.
### Wichtige Hinweise
- Vor der Verwendung sollten die Anmeldeinformationen in der XML-Konfigurationsdatei angepasst werden.
- Das Skript zielt darauf ab, den Zustand der Hyper-V-Replikation zu überprüfen und kritische Zustände zu beheben.
# Hyper-V starten
## [HyperV_restart.ps1](https://github.com/ErhardRainer/powershell_HyperV/blob/main/HyperV_restart.ps1)
näheres dazu in diesem [Blog-Artikel](https://erhard-rainer.com/2021-12/hyper-v-restart-if-not-running/)
### Kurzbeschreibung
Dieses PowerShell-Skript gewährleistet, dass ausgewählte Hyper-V VMs immer in Betrieb sind und verschickt bei einem Neustart Benachrichtigungen per E-Mail. Es überprüft periodisch den Zustand der angegebenen VMs und führt einen Neustart durch, sollten diese nicht aktiv sein. Für die E-Mail-Benachrichtigungen können Konfigurationen aus einer optionalen XML-Datei geladen werden.
### Voraussetzungen
* Hyper-V muss auf dem Host-System installiert und konfiguriert sein.
* PowerShell
* Eine konfigurierte XML-Datei für E-Mail-Einstellungen (optional).
### Technische Umsetzung
Das Skript akzeptiert zwei Parameter:
- **VMNames**: Eine durch Kommata getrennte Liste der Namen der zu überwachenden VMs.
- **ConfigPath**: Der Pfad zur optionalen XML-Konfigurationsdatei für die E-Mail-Benachrichtigungseinstellungen.
Zuerst lädt das Skript die E-Mail-Einstellungen aus der XML-Konfigurationsdatei, falls vorhanden. Anschließend durchläuft es die Liste der VMs, prüft deren Zustand und startet sie neu, wenn sie nicht laufen. Bei einem Neustart wird, falls konfiguriert, eine E-Mail-Benachrichtigung versendet.
### Funktionen und Parameter
- **Get-EmailSettings** lädt die E-Mail-Einstellungen aus der angegebenen XML-Datei.
- **VMNames** und **ConfigPath** sind die Parameter, die das Verhalten des Skripts steuern.
### Beispiele
Ausführung des Skripts, um die VMs 'MS BI' und 'SQL Server' zu überwachen und E-Mail-Einstellungen aus 'mysettings.xml' zu laden:
> .\HyperV_restart.ps1 -VMNames 'MS BI', 'SQL Server' -ConfigPath 'mysettings.xml'
### Versionshistorie
- 2021-12-23 - 1.0 - Erstveröffentlichung und E-Mail Versand bei Restart der VM.
- 2024-04-03 - 1.1 - Integration der Einstellungen aus XML-Datei.
## mehrere Hyper-Vs auf unterschiedlichen Servern starten
Der [Artikel](https://erhard-rainer.com/2014-03/mehrere-virtuelle-maschinen-auf-unterschiedlichen-hyper-v-hosts-starten/) beschreibt ein PowerShell-Skript, mit dem mehrere virtuelle Maschinen (VMs) auf verschiedenen Hyper-V-Hosts in einer vordefinierten Reihenfolge automatisch gestartet werden können. Dieses Verfahren wird insbesondere in Entwicklungs- oder Testumgebungen nützlich, wo verschiedene VMs zusammenarbeiten müssen. Das Skript nutzt zwei Arrays, um Hyper-V-Hosts und VM-Namen zu definieren, überprüft die Verfügbarkeit jeder VM auf den angegebenen Hosts und startet die VMs, die nicht bereits laufen. Eine praktische Lösung für Umgebungen mit verteilten Ressourcen.
# Hyper-V Export & Import
## [HyperV_Import.ps1](https://github.com/ErhardRainer/powershell_HyperV/blob/main/HyperV_Import.ps1)
### Kurzbeschreibung
Dieses PowerShell-Skript ermöglicht das Importieren einer oder mehrerer virtueller Maschinen (VMs) aus einem Backup-Verzeichnis oder das Auflisten aller in diesem Verzeichnis verfügbaren VMs. Es bietet Optionen für die Nutzung von Standardpfaden, falls keine spezifischen Pfade angegeben sind. Die Funktionalität wird über den Parameter `-Type` gesteuert.
### Voraussetzungen
* Hyper-V muss auf dem Host-System installiert und konfiguriert sein.
* PowerShell mit Administratorrechten.
* Zugriff auf das Backup-Verzeichnis der VMs.
### Technische Umsetzung
Das Skript akzeptiert mehrere Parameter:
- **ImportPath**: Pflichtparameter. Gibt den Pfad zum Backup-Verzeichnis an.
- **VmPath**: Optional. Zielverzeichnis für die importierte VM. Standardpfad wird verwendet, falls nicht angegeben.
- **VhdPath**: Optional. Zielverzeichnis für die VHDs der importierten VM. Standardpfad wird verwendet, falls nicht angegeben.
- **Type**: Pflichtparameter. Legt den Modus des Skripts fest (`List` zum Auflisten aller VMs im Backup-Verzeichnis, `Import` zum Importieren).
- **Name**: Optional. Name der spezifisch zu importierenden VM. Nur relevant im `Import`-Modus.
Es führt eine Administratorrechtsprüfung durch und initialisiert die Standardpfade für VM- und VHD-Zielverzeichnisse, falls diese nicht spezifiziert sind. Abhängig vom Modus (`List` oder `Import`) werden die entsprechenden Aktionen ausgeführt.
### Funktionen und Parameter
- **Import-VMFromPath**: Importiert eine VM anhand des angegebenen Konfigurationspfades, mit Optionen für VM- und VHD-Zielverzeichnisse.
### Beispiele
Importieren einer VM aus dem Backup-Verzeichnis:
> .\HyperV_Import.ps1 -Type Import -ImportPath "\\192.168.0.185\Backup\HyperV\"
Auflisten aller verfügbaren VMs im Backup-Verzeichnis:
> .\HyperV_Import.ps1 -Type List -ImportPath "\\192.168.0.185\Backup\HyperV\"
### Versionshistorie
- 2024-04-03 - 1.0 - Initiale Version.
- 2024-04-04 - 1.1 - Hinzufügen des `Type` Parameters und erweiterte Funktionalität.
- 2024-04-04 - 1.2 - Integration der Standardpfade für `VmPath` und `VhdPath`.
- 2024-04-04 - 1.3 - Administratorrechtsprüfung hinzugefügt.
## [HyperV_Sichern.ps1](https://github.com/ErhardRainer/powershell_HyperV/blob/main/HyperV_Sichern.ps1)
### Kurzbeschreibung
Dieses PowerShell-Skript ist für das Backup von Hyper-V VMs konzipiert. Es bietet verschiedene Modi für den Export: Live-Export der VMs, Überspringen laufender VMs oder Herunterfahren der VMs vor dem Export. Die Spezifikation des Backup- und des temporären Exportverzeichnisses, sowie des Exporttyps erfolgt über Parameter.
### Voraussetzungen
* Hyper-V muss auf dem Host-System installiert und konfiguriert sein.
* Genügend Speicherplatz im angegebenen Backup- und temporären Exportverzeichnis.
* PowerShell mit Administratorrechten.
### Technische Umsetzung
Das Skript nutzt drei Hauptparameter:
- **BackupPath**: Der Netzwerkpfad für das Backup der VMs. Standardmäßig ist dieser auf `\\192.168.0.185\Backup\HyperV` gesetzt.
- **TmpExport**: Das lokale temporäre Verzeichnis für den Export. Standardmäßig ist dieses auf `f:\Backup` gesetzt.
- **ExportType**: Gibt den Typ des Exports an. Mögliche Werte sind `1` für Live-Export, `2` für das Überspringen laufender VMs, und `3` für Herunterfahren, Exportieren und Hochfahren. Standard ist `2`.
Die Durchführung des Backups beginnt mit der Überprüfung der Existenz der angegebenen Verzeichnisse. Es werden alle verfügbaren VMs aufgelistet und je nach Exporttyp spezifische Schritte durchgeführt. Der Export erfolgt in ein temporäres Verzeichnis, von wo aus er dann in das finale Backup-Verzeichnis kopiert wird. Abschließend erfolgt ein Vergleich der Dateigrößen zur Überprüfung der Integrität und eine Bereinigung des temporären Verzeichnisses.
### Funktionen und Parameter
- Überprüfung der Existenz von Backup- und temporärem Exportverzeichnis.
- Durchführung des Exports basierend auf dem konfigurierten Modus.
- Integritätsprüfung der kopierten Dateien und Bereinigung des temporären Verzeichnisses.
- Optional: Neustart der VMs nach dem Export.
### Beispiele
Durchführung eines Live-Exports der VMs in ein spezifisches Backup- und temporäres Exportverzeichnis:
> .\VMBackup.ps1 -BackupPath "\\192.168.0.200\Backup\HyperV" -TmpExport "c:\TempBackup" -ExportType 1
### Versionshistorie
- 1.0 - Initiale Version
# virtuelle Festplatten
## [MergeVHDs.ps1](https://github.com/ErhardRainer/powershell_HyperV/blob/main/MergeVHDs.ps1)
### Kurzbeschreibung
Dieses PowerShell-Skript durchläuft ein spezifiziertes Verzeichnis, um alle .avhdx (Differenzierungs-) und .vhdx (virtuelle Festplatten-) Dateien basierend auf ihrer Eltern-Kind-Beziehung zu zusammenzuführen. Optional wird zuvor eine Sicherungskopie der Originaldateien erstellt.
### Voraussetzungen
* PowerShell
* Zugriff auf ein Verzeichnis mit VHDX und AVHDX Dateien.
* Hyper-V muss auf dem System installiert sein, um `Merge-VHD` nutzen zu können.
### Technische Umsetzung
Das Skript nimmt den Pfad zum Verzeichnis mit den zu zusammenführenden Dateien als obligatorischen Parameter entgegen. Es bietet die Option, eine Sicherungskopie des Verzeichnisses zu erstellen, bevor es mit der Zusammenführung der Dateien beginnt. Die Dateien werden aufsteigend nach ihrem letzten Bearbeitungsdatum sortiert und dann entsprechend ihrer Eltern-Kind-Beziehung zusammengeführt.
### Funktionen und Parameter
- **Create-Backup**: Erstellt eine Sicherungskopie des Verzeichnisses mit VHDX und AVHDX Dateien.
- **Get-BackupConfirmation**: Fragt den Benutzer, ob eine Sicherungskopie erstellt werden soll.
- **directoryPath**: Der Pfad zum Verzeichnis mit den VHDX und AVHDX Dateien, die zusammengeführt werden sollen.
### Beispiele
Zusammenführen von VHDX und AVHDX Dateien in einem spezifizierten Verzeichnis nach Erstellung einer Sicherungskopie:
> .\MergeVHDs.ps1 -directoryPath "C:\Pfad\Zum\Verzeichnis"
## weiterführender Artikel
Der [Artikel](https://erhard-rainer.com/2012-09/hyper-v-vhd-dateien-zusammenfuhren/) bietet verschiedene Ansätze, um Hyper-V VHD-Dateien zusammenzuführen, darunter das Entfernen von Snapshots über Hyper-V und eine Komprimierung, die Verwendung eines Videos als Anleitung zum Zusammenführen sowie eine PowerShell-Lösung mit der Merge VHD Funktion. Letztere nutzt die Msvm_ImageManagementService WMI-Klasse, um die Dateien zu verschmelzen, wobei der Fortschritt überwacht wird. Es wird auch die Idee angesprochen, aus einem Snapshot einen lauffähigen Klon zu erstellen.
# Snapshots
## HyperV Snapshots
Der Artikel [ERSTELLUNG EINER LISTE VON HYPER-V SNAPSHOTS UND GENERIERUNG LAUFFÄHIGER MASCHINEN AUS SNAPSHOTS MITTELS POWERSHELL](https://erhard-rainer.com/2023-11/erstellung-einer-liste-von-hyper-v-snapshots-und-generierung-lauffahiger-maschinen-aus-snapshots-mittels-powershell/) beschreibt, wie man mit PowerShell eine Liste von Hyper-V Snapshots erstellt und daraus lauffähige Maschinen generiert. Er bietet Einblicke in die Funktionsweise von Hyper-V und Snapshots, zeigt Schritte zum Auflisten von Snapshots mittels PowerShell und erläutert, wie aus einem Snapshot eine neue VM erstellt werden kann, indem die Original-VM dupliziert und der Snapshot auf diese Kopie angewendet wird. Der Artikel betont die Bedeutung von Anpassungen und Vorbereitungen wie Speicherplatzprüfung und Berechtigungen, um Netzwerkkonflikte und Lizenzierungsprobleme zu vermeiden.
siehe dazu auch [hier](https://erhard-rainer.com/2021-11/hyper-v-checkpoints/)

## HyperV_VMInformation.ps1 (comming soon)

Dieses Skript dient dazu einne Power BI Report über den Status (historisch) der Hyper-V Maschinen aufzubauen.
Aus diesem Grund wird eine Reihe von Informationen extrahiert. 

Darüberhinaus empfehle ich, die Verwendung Hyper-V Health Reports mit einem kleinen Webserver auf jedem Hyper-V Host, um schnell einen Überblick über die wichtigsten Informationen zu haben. 
https://gist.github.com/jdhitsolutions/d6ec76a00525f18d87ca27d104ea00bd
https://jdhitsolutions.com/blog/powershell/7047/my-powershell-hyper-v-health-report/

## HyperV_RestartFromSharepoint.ps1 (comming soon)

Dieses Skript dient dazu eine Sharepoint Liste mit einer Liste aller virtuellen Maschinen zu aktualisieren. 
Wird in der Sharepoint Liste der Status auf "toStart" geändert, wird am Hyper-V Server die VM gestartet.
Wird in der Sharepoint Liste der Status auf "toShutdown" geändert, wird am Hyper-V Server die VM gestoppt. 

## HyperV_FailoverStart.ps1 (comming soon)

Dieses Skript dient dazu, wenn der Haupt-HyperV Server über die Dauer von 20 Minuten nicht erreichbar ist
(a) ein Mail auszusenden
(b) am Replication Server die Hyper-V Maschine zu starten
Wichtig ist, dass nicht nur die virtuelle Maschine sondern der gesamte Haupt-HyperV Server nicht erreichbar ist. 

# ToDo
- Finalisierung der (comming soon) Skripte
- HyperV_Import.ps1 funktioniert nicht immer
