[CmdletBinding()]
Param (
    [Parameter(Mandatory)]
    [string]$ADGroup,
    [Parameter(Mandatory)]
    [string]$UserName,
    [switch]$Passthru,
    [string]$ADServer="<>",
    [string]$ADUser="<>",
    [string]$ADPassword="<>",
    [string]$flag = ""

)

$error.Clear()
#Save output msgs
$ErrorActionPreference = "SilentlyContinue"
$UserExists ="*already a member*"
$couldnotadd= "Could Not Add User"
$nouser ="does not exists in Database, Please enter correct GUID."
$emptyuser ="UserName is Empty."
$msgGroupNotFound = "Not able to find Group"
$ADGroup = $ADGroup.Replace('-amp_char-','&')


$secpasswd = ConvertTo-SecureString "$ADPassword" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("$ADUser", $secpasswd)
$Result = @()

$arrGroups = $ADGroup.Split(';')

$CheckUsers = Get-ADUser -Identity $UserName -Server $ADServer -Credential $mycreds
    if($CheckUsers) #Check if Valid User.
     {
     
  ForEach ($Group in $arrGroups)
    {   

       if($Group)
       {
      #  }
      #  {
        $CheckGroups=$null   
        $CheckGroups=Get-ADGroup -Identity $Group -Server $ADServer -Credential $mycreds

        if($CheckGroups) #Check for valid Group.
        
        {
            Add-ADGroupMember -Identity $Group -Members $UserName -Server $ADServer -Credential $mycreds
               if ($error.Count -eq "0") #User Added Successfully
                {
                 Write-Host "User $UserName is Added to $Group."
                 $flag += "Success"
                 #Write-Host "$flag"
                     }

               else
                    {
                      if($error -like $UserExists)#User Already a Member
                         {
                         Write-Host "User $UserName is Already a Member of $Group."
                         $flag += "Success"
                         #Write-Host "$flag"    
                         }
                                
                       else #error
                             {
                             Write-Host "$couldnotadd $UserName to group $Group." #Could not add user.
                             $flag += "Failed"
                             #Write-Host "$flag"
                             }                                                   
                                                                                    
                    }
          }

          else
          {
          Write-Host "$msgGroupNotFound $Group" #Group Not Valid
          $flag += "Failed"
          #Write-Host "$flag"
          }
                    
      $error.Clear()
           
  }
  }
          }

    else {
         Write-Host "$UserName $nouser" #User not found.
         $flag += "Failed"
         }


 


  if($flag -like "*Failed*")
  {
  Write-Host "Failed"
  }

  else
  {
  Write-Host "Success"
  }