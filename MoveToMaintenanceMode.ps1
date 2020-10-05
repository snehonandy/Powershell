[CmdletBinding()]
#Parameter Declaration
Param(
  [Parameter(Mandatory=$True)]
   [string]$VDIName
)


$controller = ""
$remotesession = New-PSSession -ComputerName $controller
Invoke-Command -Command {Add-PSSnapin Citrix.*} -Session $remotesession     
Import-PSSession -Session $remotesession -Module Citrix.* -Prefix RM -AllowClobber
$error.Clear()
New-RMBrokerHostingPowerAction -MachineName $VDIName -Action shutdown
sleep -Seconds 120
$VDI = Set-RMBrokerPrivateDesktop "$VDIName" -InMaintenanceMode $True


Write-Host $VDI


if($error.Count -eq '0')
{
    Write-Host "Success"
}
else
{
    Write-Host "Failed"
}

(Get-WmiObject Win32_Process -ComputerName $controller -ErrorAction SilentlyContinue | ?{ $_.ProcessName -match "wsmprovhost" }).Terminate()