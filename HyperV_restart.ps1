<#	
	.NOTES
	===========================================================================
	 Created on:   	2021-12-23
	 Created by:   	Erhard Rainer
	 Filename:     	HyperV_restart.ps1
	===========================================================================
	.DESCRIPTION
        Dieses Script stellt sicher, dass bestimmte VMs immer laufen
    .VERSION HISTORY
        2021-12-23 - ER - Email Versand bei Restart der VM
#>

## globale Variable - hier wird konfiguriert, welche VMs laufen müssen
$VMNames = $array = @('MS BI')


for ($i=0; $i -lt $VMNames.length; $i++)
{
    $VMName = $VMNames[$i]
    $VM = (Get-VM | Where { $_.State –ne 'Running' -and $_.Name -eq $VMName})
    if (($VM | Measure-Object).Count -ne 0) 
    {
        Write-Host "Hyper-V war nicht verfügbar und musste neu gestartet werden" -ForegroundColor Red

        Write-Host "Send Mail because Hyper-V Restarted"
        $EmailFrom = "xy@googlemail.com"
        $EmailTo = "ab@gmail.com"
        $Subject = "TEST"
        $Body = "this is a notification from XYZ Notifications.."
        $SMTPServer = "smtp.gmail.com"
        $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
        $SMTPClient.EnableSsl = $true
        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("username", "pw");
        $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)

        Start-VM $VM 
    } else {
        Write-Host "Hyper-V war verfügbar und läuft" -ForegroundColor Green
        (Get-VM | Where { $_.State –eq 'Running' -and $_.Name -eq $VMName}) | Measure-VM
    }
}