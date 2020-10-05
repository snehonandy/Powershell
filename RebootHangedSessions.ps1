

$ADServer = "pbi.global.pvt"
$ADUser = "pbi\bmcao-s"
$ADPassword = "poiuyt1a"
$secpasswd = ConvertTo-SecureString "poiuyt1a" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("pbi\bmcao-s", $secpasswd)


$controller = "USAWE-CTXDCPC02.pbi.global.pvt"
$remotesession = New-PSSession -ComputerName $controller
Invoke-Command -Command {Add-PSSnapin Citrix.*} -Session $remotesession     
Import-PSSession -Session $remotesession -Module Citrix.* -Prefix RM -AllowClobber
 
$ConnectedVMs=Get-RMBrokerSession -MaxRecordCount 600 | where {$_.Powerstate -eq "On" -and $_.SessionState -eq "Connected"} | select MachineName, SessionStateChangeTime, ClientName, BrokeringUserName
$date=Get-Date

if(!$ConnectedVMs)
{}
Else 
 { 
         Foreach ($VM in $ConnectedVMs)
        {
            $timediff = $date - $VM.SessionStateChangeTime
 
            if ($timediff.TotalMinutes -gt 15)
            {   
            
            $Error.Clear()
               
                New-RMBrokerHostingPowerAction -Action Reset -MachineName $VM.MachineName               
               
               $UserName = $VM.BrokeringUserName
               $User = $UserName.SubString(4,7)
               $VM | Out-File "D:\ScriptRepo\VDI Session Reboot\$User-RebootedServer$((Get-Date).ToString('yyyy-MM-dd')).txt"
               $VM | Export-CSV -Append -Path "D:\ScriptRepo\VDI Session Reboot\Master-RebootedServer.csv" -NoTypeInformation
               $DisplayName = Get-ADUser -Identity $User -Properties * | Select DisplayName
               $DisplayName = $DisplayName.DisplayName
               $GetManaGer = (get-aduser (get-aduser $User -Properties manager).manager).samaccountName
               $smtpServer = "mymail.pb.com"
               $smtpFrom = "ToolsSharedBox@pb.com"
               
               $smtpTo = "<$User@pb.com>","<$GetManaGer@pb.com>"
               $smtpBcc = "<vinuraj.ramakrishnan@pb.com>","<nex26bn@pb.com>"
               $messageSubject = "VDI Session has been Restarted for the User $User"

               $messageBody = @"
Hi $DisplayName

Based on our report the Citrix desktop connection for user id $User is in Disconnected ("Hung") Session.

We have restarted your session to fix the issue, try logging on again please.

Regards,

PB Citrix Support Team

    *******PLEASE DO NOT REPLY TO THIS EMAIL. FOR ANY CONCERN CONTACT SDSC TEAM FOR ASSISTENCE*********
"@
               Send-MailMessage -To $smtpTo -Bcc $smtpBcc -From $smtpFrom -Subject $messageSubject -Body $messageBody -SmtpServer $smtpServer -Attachments "D:\ScriptRepo\VDI Session Reboot\$User-RebootedServer$((Get-Date).ToString('yyyy-MM-dd')).txt" -Port 25
             }
            Else
            {                
            }
         }

               if($Error.Count -eq 0)
               {
               Return "Success"
               #
               }
               else
               {
                Return "Error $Error"
                #Send-MailMessage -To $smtpTo -From $smtpFrom -Subject $messageSubject -Body $messageBody -SmtpServer $smtpServer -Attachments "D:\ScriptRepo\VDIManagement\RebootedServer$((Get-Date).ToString('yyyy-MM-dd')).txt" -Port 25
               }
 }
(Get-WmiObject Win32_Process -ComputerName $controller -ErrorAction SilentlyContinue | ?{ $_.ProcessName -match "wsmprovhost" }).Terminate()