[CmdletBinding()]
#Parameter Declaration
Param(
  [Parameter(Mandatory=$True)]
   [string]$UserName,
 
   [Parameter(Mandatory=$True)]
   [string]$CitrixCatalogName
)


$controller = ""
$remotesession = New-PSSession -ComputerName $controller
Invoke-Command -Command {Add-PSSnapin Citrix.*} -Session $remotesession     
Import-PSSession -Session $remotesession -Module Citrix.* -Prefix RM -AllowClobber
$UserName="PBI\$UserName"

$VDI = Get-RMBrokerDesktop -CatalogName $CitrixCatalogName -AssociatedUserName $UserName

$MachineInMaintenanceMode = $VDI.InMaintenanceMode
$machineName=$VDI.MachineName

Write-Host "InMaintenanceMode="$MachineInMaintenanceMode 




