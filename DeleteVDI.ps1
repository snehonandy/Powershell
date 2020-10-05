[CmdletBinding()]
#Parameter Declaration
Param(
  
   [Parameter(Mandatory=$True)]
   [string]$vdi,

   [Parameter(Mandatory=$True)]
   [string]$UserName,

   [Parameter(Mandatory=$True)]
   [string]$ADGroup
)

$Error.Clear()

$ADServer = ""
$ADUser = ""
$ADPassword = ""
$secpasswd = ConvertTo-SecureString $ADPassword -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($ADUser, $secpasswd)


$controller = ""

$remotesession = New-PSSession -ComputerName $controller
Invoke-Command -Command {Add-PSSnapin Citrix.*} -Session $remotesession     
Import-PSSession -Session $remotesession -Module Citrix.* -Prefix RM -AllowClobber



$trim_vdi=$vdi.Substring($vdi.IndexOf('\')+1)
$XDesktop = Get-RMBrokerMachine -MachineName $vdi
$DesktopGroupName = $XDesktop.DesktopGroupName
$VDI_SID = $XDesktop.SID
$XDesktop | Set-RMBrokerMachineMaintenanceMode -MaintenanceMode $True

$Provision_UID = Get-RMProvVM  -AdminAddress "$controller:80" -VMName $trim_vdi
$ProvUID=$Provision_UID.ProvisioningSchemeUid
$VM_ID = Get-RMProvVM  -AdminAddress "$controller:80" -VMName $trim_vdi
$VMId = $VM_ID.VMId

################CITRIX CONSOLE DELETION################

Remove-RMBrokerMachine -AdminAddress "$$controller:80" -DesktopGroup "$DesktopGroupName" -MachineName "$vdi" -Force
Remove-RMBrokerMachine -AdminAddress "$$controller:80" -MachineName "$vdi" -Force
########################################################

################AWS DELETION###########################
Unlock-RMProvVM  -AdminAddress "$controller:80" -ProvisioningSchemeUid $ProvUID -VMID @($VMId)
Get-RMProvScheme  -AdminAddress "$controller:80" -MaxRecordCount 2147483647 -ProvisioningSchemeUid $ProvUID
Remove-RMProvVM  -AdminAddress "$controller:80" -ProvisioningSchemeUid $ProvUID -RunAsynchronously -VMName @($trim_vdi)
########################################################
$GetPoolID=Get-RMProvScheme  -AdminAddress "$controller:80" -MaxRecordCount 2147483647 -ProvisioningSchemeUid $ProvUID
$PoolID=$GetPoolID.IdentityPoolUid
################DELETE  MACHINE FROM AD####################
Remove-RMAcctADAccount  -ADAccountSid @("$VDI_SID") -AdminAddress "$controller:80" -Force -RemovalOption "Delete"
Remove-RMAcctADAccount  -IdentityPoolUid $PoolID -ADAccountSid @($VDI_SID) -AdminAddress "$controller:80" -Force -RemovalOption Delete
###########################################################

$GetPoolID
if($Error.Count -eq '0')
{
$Result = "Success"
}
else
{
$Result = "Failed"
}


$Error.Clear()
Remove-ADGroupMember -Identity $ADGroup -Members $UserName -Server $ADServer -Credential $mycreds -ErrorAction SilentlyContinue -Confirm:$false


if($Error.Count -eq '0')
{
Write-Host "Success"
}
else
{
Write-Host "Failed"
}

(Get-WmiObject Win32_Process -ComputerName $controller -ErrorAction SilentlyContinue | ?{ $_.ProcessName -match "wsmprovhost" }).Terminate()
