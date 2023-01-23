# powershell_HyperV
diverse Powershell Skripte rund um Hyper-V

ProjektStatus: vorerst abgeschlossen (sollten neue Scripte meinerseits benötigt werden, dann werde ich das Projekt eventuell wieder aufnehmen)

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

############ HyperV_VMInformation.ps1

Dieses Skript dient dazu einne Power BI Report über den Status (historisch) der Hyper-V Maschinen aufzubauen.
Aus diesem Grund wird eine Reihe von Informationen extrahiert. 

Darüberhinaus empfehle ich, die Verwendung Hyper-V Health Reports mit einem kleinen Webserver auf jedem Hyper-V Host, um schnell einen Überblick über die wichtigsten Informationen zu haben. 
https://gist.github.com/jdhitsolutions/d6ec76a00525f18d87ca27d104ea00bd
https://jdhitsolutions.com/blog/powershell/7047/my-powershell-hyper-v-health-report/
