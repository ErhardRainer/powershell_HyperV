<#
.SYNOPSIS
Dieses Skript prüft Hyper-V-Replikationen auf dem lokalen Computer und meldet eventuelle Probleme. Bei Fehlern in der Replikation werden detaillierte Informationen per E-Mail gesendet und ein Versuch zur erneuten Synchronisation kritischer Fälle wird unternommen.

.NAME
CheckHyperVReplications.ps1

.DESCRIPTION
Dieses Skript überprüft den Zustand der Hyper-V-Replikationen auf dem lokalen Computer, generiert einen Bericht und sendet diesen bei Bedarf per E-Mail. Es versucht auch, Replikationen im kritischen Zustand automatisch neu zu synchronisieren. Die Konfiguration erfolgt über eine externe XML-Datei.

.AUTHOR
Erhard Rainer
http://erhard-rainer.com

.DATE
2024-04-03

.EXAMPLE
PS> .\CheckHyperVReplications.ps1

.PARAMETER mysettings.xml
Die XML-Konfigurationsdatei, die Einstellungen für Replikationslogs, E-Mail-Einstellungen und andere Skriptparameter enthält.

.VERSIONHISTORY
2021-11-15 - 1.0 - Erstveröffentlichung
2022-01-01 ER Settings from XML
2022-01-01 ER also logging to Network Share => for Power BI Report
2022-12-13 ER also Start Resyncing

.IMPORTANT
Change Credentials before Use. Checks Replication Hyper-V and attempts to resync critical replication states.

.NOTES
Lizenz: Creative Commons Attribution 4.0 International License (CC BY 4.0)
#>

Write-Host "-------------------------------------------------------"
Write-Host "             Checking Hyper-V Replications"
Write-Host "-------------------------------------------------------"

$computer = ($env:computername)
[xml]$config = Get-Content "mysettings.xml"
$timestamp = ($(get-date -f yyyyMMdd)+$(get-date -f HHmmss))
$count = (Get-VMReplication -ComputerName $computer | Where-Object { $_.Health -ne "Normal"}).Count
$res = (Measure-VMReplication | Select-Object * | ConvertTo-Html)
Measure-VMReplication | Select-Object * | Export-Clixml  (-join($config.Settings.ReplicationSettings.LogPath,"replication_",$timestamp,".xml"))

Write-Host "Not Normal Working Replications: $count"

if ($count -gt 0)
{
    Write-Host "Send Mail because Replication Error"
    $EmailFrom = $config.Settings.EmailSettings.MailFrom
    $EmailTo = $config.Settings.EmailSettings.MailTO
    $Subject = "Hyper-V Replication ERROR"
    $Body = $res

    $mail = New-Object System.Net.Mail.Mailmessage $EmailFrom, $EmailTo, $Subject, $Body
    $mail.IsBodyHTML=$true

    $SMTPServer = $config.Settings.EmailSettings.SMTPServer
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $config.Settings.EmailSettings.SMTPServer)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($config.Settings.EmailSettings.MailUsername, $config.Settings.EmailSettings.MailPassword);
    $SMTPClient.Send($mail)
}

## Try to Resync Hyper-V that are Critical
$wait = 5

Get-VMReplication -ComputerName $computer | Format-Table -Property VMName, ReplicationHealth, State

$FailedReplications = Get-VMReplication -ComputerName $computer | Where-Object {$_.ReplicationHealth -eq "Critical"}

$FailedReplications | ForEach-Object {
$VMName = $_.VMName
Write-Host $VMName -ForegroundColor Red
if ($_.State -ne "Resynchronizing")
    {
        Write-Host "Replication is resynchronizing $_.VMName"
        Resume-VMReplication -VMName $VMName -ReplicaServer $computer
        Start-Sleep -Seconds ($wait * 60)
        $ReplicationStatus = Get-VMReplication -ComputerName $computer -VMName $_.VMName | Where-Object {$_.State -eq "Resynchronizing"}
        If ($ReplicationStatus) {
            Write-Host "Replication $VMName is resynchronizing" -BackgroundColor Green -ForegroundColor Black
        }
        Else {
            Write-Host "Restarting $VMName Replication failed." -BackgroundColor Red -ForegroundColor Black
        }
    } else {
        Write-Host "Replication $VMName already resyncing" -BackgroundColor Yellow -ForegroundColor Black
    }
}
