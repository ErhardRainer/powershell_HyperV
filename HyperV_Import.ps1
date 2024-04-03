<#
.SYNOPSIS
Importiert eine virtuelle Maschine (VM) aus einem Backup-Verzeichnis oder listet alle verfügbaren VMs auf, mit Optionen für Standardpfade.

.DESCRIPTION
Dieses Skript kann entweder eine oder mehrere VMs aus einem angegebenen Backup-Verzeichnis importieren oder alle im Backup-Verzeichnis verfügbaren VMs auflisten. Der Modus wird über den Parameter -Type gesteuert. Standardpfade werden verwendet, wenn keine spezifischen Pfade angegeben sind.

.AUTHOR
Erhard Rainer
http://erhard-rainer.com

.DATE
2024-04-04

.EXAMPLE
PS> .\HyperV_Import.ps1 -Type Import

.EXAMPLE
PS> .\HyperV_Import.ps1 -Type List -ImportPath "\\192.168.0.185\Backup\HyperV\"

.PARAMETER ImportPath
Pfad zum Verzeichnis, in dem das VM-Backup gespeichert ist.

.PARAMETER VmPath
Optionaler Parameter. Zielverzeichnis für die importierte VM. Wenn nicht gesetzt, wird der Standardpfad verwendet.

.PARAMETER VhdPath
Optionaler Parameter. Zielverzeichnis für die VHDs der importierten VM. Wenn nicht gesetzt, wird der Standardpfad verwendet.

.PARAMETER Type
Der Modus des Skripts: 'List' für das Auflisten aller VMs im Backup-Verzeichnis, 'Import' für das Importieren einer oder mehrerer VMs.

.PARAMETER Name
Optionaler Parameter. Der Name der spezifischen VM, die importiert werden soll. Nur relevant, wenn Type auf 'Import' gesetzt ist.

.VERSIONHISTORY
2024-04-03 - 1.0 - Initiale Version
2024-04-04 - 1.1 - Hinzufügen des Type Parameters und erweiterte Funktionalität
2024-04-04 - 1.2 - Integration der Standardpfade für VmPath und VhdPath
2024-04-04 - 1.3 - Administator Prüfung eingebaut

.NOTES
Lizenz: Creative Commons Attribution 4.0 International License (CC BY 4.0)
#>

param(
    # ImportPath ist verpflichtend
    [Parameter(Mandatory=$true)]
    [string]$ImportPath,

    # VmPath ist optional
    [Parameter(Mandatory=$false)]
    [string]$VmPath,

    # VhdPath ist optional
    [Parameter(Mandatory=$false)]
    [string]$VhdPath,

    # Type ist verpflichtend und muss entweder 'List' oder 'Import' sein
    [Parameter(Mandatory=$true)]
    [ValidateSet('List', 'Import')]
    [string]$Type,

    # Name ist optional
    [Parameter(Mandatory=$false)]
    [string]$Name
)

# Funktion zum Importieren von VM(s) basierend auf einem Pfad
function Import-VMFromPath {
    param(
        [string]$VmConfigPath,
        [string]$VmPath,
        [string]$VhdPath
    )
    try {
        $importedVm = Import-VM -Path $VmConfigPath -Copy -VhdDestinationPath $VhdPath -VirtualMachinePath $VmPath
        Write-Host "VM wurde erfolgreich importiert: $($importedVm.VMName)"
    } catch {
        Write-Error "Fehler beim Importieren der VM aus dem Pfad VmConfigPath: $_"
    }
}

# Überprüfung, ob das Skript als Administrator ausgeführt wird
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Dieses Skript muss als Administrator ausgeführt werden."
    exit
}

# Ermittlung der Standardpfade, falls notwendig
if (-not $VmPath) {
    $VmPath = (Get-VMHost).VirtualMachinePath
}
if (-not $VhdPath) {
    $VhdPath = (Get-VMHost).VirtualHardDiskPath
}

# Initialisierung des Rückgabewertes
$success = $false

switch ($Type) {
    'List' {
        # Listet alle verfügbaren VMs im Import-Path auf
        try {
            $vms = Get-ChildItem -Path $ImportPath -Directory
            Write-Host "Verfügbare VMs im Verzeichnis $ImportPath"
            $vms | ForEach-Object { Write-Host $_.Name }
            $success = $true
        } catch {
            Write-Error "Fehler beim Auflisten der VMs: $_"
        }
    }
    'Import' {
        try {
            if ($Name) {
                # Importiere spezifische VM
                $specificVmPath = Join-Path -Path $ImportPath -ChildPath $Name
                $vmcx = Get-ChildItem -Path $specificVmPath -Recurse -Filter "*.vmcx" | Select-Object -First 1
                if ($vmcx) {
                    Import-VMFromPath -VmConfigPath $vmcx.FullName -VmPath $VmPath -VhdPath $VhdPath
                } else {
                    Write-Error "Keine VM-Konfiguration (.vmcx) im Pfad $specificVmPath gefunden."
                }
            } else {
                # Importiere alle VMs
                $allVmcxFiles = Get-ChildItem -Path $ImportPath -Recurse -Filter "*.vmcx"
                foreach ($vmcx in $allVmcxFiles) {
                    Import-VMFromPath -VmConfigPath $vmcx.FullName -VmPath $VmPath -VhdPath $VhdPath
                }
            }
        } catch {
            Write-Error "Fehler beim Importieren der VM(s): $_"
        }
    }
}

# Rückgabe, ob das Skript erfolgreich war oder nicht
# return $success
