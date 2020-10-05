
[CmdletBinding()]
#Parameter Declaration
Param(
  
   [Parameter(Mandatory=$True)]
   [string]$vdi
 )


$controller = ""
$remotesession = New-PSSession -ComputerName $controller
Invoke-Command -Command {Add-PSSnapin Citrix.*} -Session $remotesession     
Import-PSSession -Session $remotesession -Module Citrix.* -Prefix RM -AllowClobber

New-RMBrokerHostingPowerAction -MachineName $vdi -Action 'Reset'

sleep -Seconds 900

$machine_state = Get-RMBrokerMachine -MachineName $vdi

$Power_State = $machine_state.PowerState

if($Power_State -eq "On")
{
    Write-Host "True"
}
else
{
    Write-Host "False"
}


(Get-WmiObject Win32_Process -ComputerName $controller -ErrorAction SilentlyContinue | ?{ $_.ProcessName -match "wsmprovhost" }).Terminate()