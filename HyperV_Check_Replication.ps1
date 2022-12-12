<#
	.NOTES
	===========================================================================
	 Created on:   	2021-12-28
	 Created by:   	Erhard Rainer
	 Filename:     	HyperV_Check_Replication.ps1
	===========================================================================
	.DESCRIPTION
        Checks Replication Hyper-V
    .NOTE
        Change Credentials before Use
    .VERSION HISTORY
        2022-01-01 ER Settings from XML
        2022-01-01 ER also logging to Network Share => for Power BI Report
        2022-12-13 ER also Start Resyncing
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
