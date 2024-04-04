<#
.SYNOPSIS
Dieses Skript stellt sicher, dass bestimmte Hyper-V VMs immer laufen und benachrichtigt per E-Mail bei Neustarts.

.DESCRIPTION
Das Skript überprüft den Status spezifizierter Hyper-V VMs und startet sie neu, falls sie nicht laufen. Konfigurationen für die E-Mail-Benachrichtigung werden aus einer optionalen XML-Datei geladen.

.AUTHOR
Erhard Rainer
http://erhard-rainer.com

.DATE
2024-04-03

.EXAMPLE
PS> .\HyperV_restart.ps1 -VMNames 'MS BI', 'SQL Server' -ConfigPath 'mysettings.xml'

.PARAMETER VMNames
Eine Liste von VM-Namen, die überwacht werden sollen.

.PARAMETER ConfigPath
Der optionale Pfad zur XML-Konfigurationsdatei für die E-Mail-Einstellungen.

.VERSIONHISTORY
2021-12-23 - 1.0 - Erstveröffentlichung und E-Mail Versand bei Restart der VM
2024-04-03 - 1.1 - Integration der Einstellungen aus XML-Datei

.NOTES
Lizenz: Creative Commons Attribution 4.0 International License (CC BY 4.0)
#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$VMNames,

    [string]$ConfigPath = "mysettings.xml"
)

# Funktion zum Laden der Konfiguration aus einer XML-Datei
function Get-EmailSettings {
    param(
        [string]$ConfigPath
    )
    if(Test-Path $ConfigPath) {
        [xml]$config = Get-Content $ConfigPath
        return $config.Settings.EmailSettings
    } else {
        Write-Host "Konfigurationsdatei nicht gefunden. Standardwerte werden verwendet." -ForegroundColor Yellow
        return $null
    }
}

# E-Mail-Einstellungen aus der XML-Datei laden, falls angegeben
$emailSettings = Get-EmailSettings -ConfigPath $ConfigPath

# Durchläuft die Liste der VMs, um ihren Status zu überprüfen
foreach ($VMName in $VMNames) {
    $VM = Get-VM | Where-Object { $_.State -ne 'Running' -and $_.Name -eq $VMName }
    
    if ($VM) {
        Write-Host "$VMName war nicht verfügbar und musste neu gestartet werden" -ForegroundColor Red

        if($emailSettings) {
            Write-Host "Sendet E-Mail, weil Hyper-V neu gestartet wurde"
            $EmailFrom = $emailSettings.MailFrom
            $EmailTo = $emailSettings.MailTO
            $Subject = "Hyper-V VM Neustart: $VMName"
            $Body = "Hyper-V VM $VMName wurde neu gestartet."

            $SMTPServer = $emailSettings.SMTPServer
            $SMTPPort = $emailSettings.SMTPPort
            $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
            $SMTPClient.EnableSsl = $true
            $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($emailSettings.MailUsername, $emailSettings.MailPassword)
            $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
        }

        # Startet die VM neu.
        Start-VM -Name $VMName
    } else {
        Write-Host "$VMName ist verfügbar und läuft" -ForegroundColor Green
        (Get-VM | Where { $_.State –eq 'Running' -and $_.Name -eq $VMName}) | Measure-VM
    }
}