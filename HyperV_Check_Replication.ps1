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
        2020-01-01 ER also logging to Network Share => for Power BI Report
#>

Write-Host "-------------------------------------------------------"
Write-Host "             Checking Hyper-V Replications"
Write-Host "-------------------------------------------------------"


[xml]$config = Get-Content "mysettings.xml"
$timestamp = ($(get-date -f yyyyMMdd)+$(get-date -f HHmmss))
$count = (Get-VMReplication | Where-Object { $_.Health -ne "Normal"}).Count
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