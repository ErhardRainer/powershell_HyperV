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
#>

$count = (Get-VMReplication | Where-Object { $_.Health -ne "Normal"}).Count
$res = (Measure-VMReplication | Select-Object * | ConvertTo-Html)
Write-Host $count

if ($count -gt 0)
{
    Write-Host "Send Mail because Replication Error"
    $EmailFrom = "xy@googlemail.com"
    $EmailTo = "ab@gmail.com"
    $Subject = "Hyper-V Replication ERROR"
    $Body = $res

    $mail = New-Object System.Net.Mail.Mailmessage $EmailFrom, $EmailTo, $Subject, $Body
    $mail.IsBodyHTML=$true

    $SMTPServer = "smtp.gmail.com"
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("username", "pw");
    $SMTPClient.Send($mail)


}