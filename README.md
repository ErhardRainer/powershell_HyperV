# powershell_HyperV
diverse Powershell Skripte rund um Hyper-V

Hierbei handelt es sich um eine Sammlung von Hyper-V Skripten, die den Betrieb eines Hyper-V Servers erleichtern

############ HyperV_Check_Replication.ps1
Dient dazu, die Replication eines Servers zu überwachen, und bei einem Zustand <> "Normal" ein Mail zu versenden.
Bei einem Zustand = "Critical" soll versucht werden die Replikation wiederzustarten. 
Das Skript ist gedacht gescheduled zu laufen und so die Replikation zu sichern.

############ HyperV_restart.ps1
Dieses Skript stellt sicher, dass bestimmte virtuelle Maschinen und falls sie nicht laufen, erneut gestartet werden.
Das Skript ist gedacht gescheduled zu laufen und so die Replikation zu sichern.

############ HyperV_RestartFromSharepoint.ps1
Dieses Skript dient dazu eine Sharepoint Liste mit einer Liste aller virtuellen Maschinen zu aktualisieren. 
Wird in der Sharepoint Liste der Status auf "toStart" geändert, wird am Hyper-V Server die VM gestartet.
Wird in der Sharepoint Liste der Status auf "toShutdown" geändert, wird am Hyper-V Server die VM gestoppt. 

############ HyperV_FailoverStart.ps1
Dieses Skript dient dazu, wenn der Haupt-HyperV Server über die Dauer von 20 Minuten nicht erreichbar ist
(a) ein Mail auszusenden
(b) am Replication Server die Hyper-V Maschine zu starten
Wichtig ist, dass nicht nur die virtuelle Maschine sondern der gesamte Haupt-HyperV Server nicht erreichbar ist. 
