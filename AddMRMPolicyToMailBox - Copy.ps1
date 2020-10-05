[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$UserName,
   
	
   [Parameter(Mandatory=$True)]
   [string]$ConnectionURI
   #https://mail.o365.abc.com/powershell

)

$error.Clear()
$ADServer = "<>"
$ADUser = "<>"
$ADPassword = "<>"
$secpasswd = ConvertTo-SecureString $ADPassword -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($ADUser, $secpasswd)

$session=New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionURI -Credential $mycreds -Authentication basic –AllowRedirection
$importresults=Import-PSSession $session -AllowClobber

$checkmailbox=$null
$checkmailbox = Get-Mailbox -Identity $UserName
if($checkmailbox)
    {
		#Apply MRM policy to Mailbox
        #Set-Mailbox $UserName -RetentionPolicy "MailboxRetentionPolicy"
		#Apply MRM policy to Mailbox with Skype extensionAttribute12 and extensionAttribute14
        Set-ADUser -Identity $UserName -Add @{extensionAttribute12='15';extensionAttribute14='UL=US|Conf=2|'} -Server $ADServer -Credential $mycreds
    }
else
    {

        $CheckEmailAddress = $null
        $CheckEmailAddress = Get-ADUser -Identity $UserName -Server 'usdc1-pbiadqv01.ct.pb.com' -Credential $mycreds -Properties EmailAddress 
        $EmailAddress = $CheckEmailAddress.EmailAddress
        if($EmailAddress)
        {
            $IsValidEmail = $EmailAddress.Contains("@abc.com")
            if( $IsValidEmail)
            {
                Write-Host "Failed- $EmailAddress - $IsValidEmail"
            }
            else
            {
                Write-Host "$UserName Mailbox not found. Email is not a PB EMail Address:$EmailAddress. MRM cannot be applied."
            }
        }
        else
        {
             Write-Host "$UserName Mailbox not found. Email Address Does not Exist for the user."
        }
       
        EXIT
    }

if ($error.Count -eq "0")
{
Write-Host "Added"
}
else
{
Write-Host "Failed"
}