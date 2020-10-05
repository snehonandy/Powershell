
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$ADId,
  [Parameter(Mandatory=$True,Position=1)]
   [string]$SAccountName,
  [Parameter(Mandatory=$True,Position=1)]
   [string]$RndPassword,
  [Parameter(Mandatory=$True,Position=1)]
   [string]$Description
   
   )


# Add the Active Directory bits and not complain if they're already there
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# set default password
$defpassword = (ConvertTo-SecureString $RndPassword -AsPlainText -force)

# Get domain DNS suffix
$ADServer=""
$ADUser=""
$ADPassword=""

$secpasswd = ConvertTo-SecureString $ADPassword -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($ADUser, $secpasswd)

# Import the file with the users. You can change the filename to reflect your file

$error.Clear()
#$ADId= $ADid -replace '\s',''
$checkuser=$null
$checkuser = Get-ADUser -Identity $ADId -Server $ADServer -Credential $mycreds -ErrorAction "SilentlyContinue" 

if ($error.Count -eq "0") 
 {
    if($checkuser){
        Write-Output "User Creation Failed. User $ADId Already Exist." 
    }
    else{
        Write-Output "User Creation Failed, User Dose not exist. $error"
    }
 } 
 else
 {
    try {
	$UPN =  $ADId + "@qc.GLBDEV.PVT"
        New-ADUser -SamAccountName $ADId -Name $SAccountName -UserPrincipalName $UPN -Description $Description -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $true -PasswordNeverExpires $true -AccountPassword $defpassword -PassThru -Server $ADServer -Credential $mycreds -Path "OU=<>,OU=<>,DC=<>,DC=<>,DC=<>"
        Write-Output "User $ADId Created Succcessfully."
    }
    catch [System.Object] {
        Write-Output "User Creation Failed. Could not create user $($user.SamAccountName), $_"
    }
 }
  
