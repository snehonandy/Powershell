<#
.Synopsis
   Merge multipe csv files with same header
.DESCRIPTION
   This script will help you to merge multipe csv files from specified folder having same header information. User need to update the header information manually before running the script.
.EXAMPLE
   Merge-CSVFiles -Path "C:\Users\TSTMOS10\Desktop\Merge" -Filter "Name Results.csv" -MergedFileName "MyMergedFile1"
.EXAMPLE
   Merge-CSVFiles -Path "C:\Users\TSTMOS10\Desktop\Merge" -Filter "Name Results.csv" -MergedFileName "MyMergedFile.csv"
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Update the script before use based on the .csv file headers you have
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   This script will help you to merge multipe csv files from specified folder having same header information. User need to update the header information manually before running the script.
#>
function Merge-CSVFiles
{
    [CmdletBinding()]
    
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,
        [Parameter(Mandatory=$true, 
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $MergedFileName,

        # Param2 help description
        [Parameter(Mandatory=$false, Position=2)]
        [String]
        $Filter
    )

    Begin
    {
       
    }
    Process
    {
        try
        {
            if($Filter -ne $null -and $Filter -ne "")
            {
                $AllFilesToMerge = Get-ChildItem -Path "$Path" -File -Filter "$Filter" -Recurse
            }
            else
            {
                $AllFilesToMerge = Get-ChildItem -Path "$Path" -Recurse
            }

            Write-Host -ForegroundColor Green "Number of files found:"$AllFilesToMerge.Count
            Start-Sleep -Seconds 5
            $CSVContentList = @()
            $CSVContentObj = @()

            foreach( $FileToMerge in $AllFilesToMerge)
            {
                $csvContent = $null
                    
                $roomName = $FileToMerge.DirectoryName.SubString($FileToMerge.DirectoryName.LastIndexOf("\")+1)
                #Write-Host -ForegroundColor Cyan "Processing RoomName:"$roomName
                Write-Host -ForegroundColor Cyan "Processing File:"$FileToMerge.Name

                $csvFilePath = $FileToMerge.FullName
                $csvContent = Import-Csv -Path "$csvFilePath"
                if($csvContent -ne $null)
                {
                    foreach($entry in $csvContent)
                    {
                        #You can also get the headers of particular .csv file like below - commented
                        #$CSVContentObj = $csvContent | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

                        #Creating custom PS Object to hold the content temporarily
                        $CSVContentObj = 1 | select RoomName, SourceName, SourceURL, RectifiedName
                        $CSVContentObj.RoomName = $roomName
                        #TODO: User need to update the headers manually before using this function
                        #$entry."<HeaderName>"    
                        $CSVContentObj.SourceName = $entry."Source Name"
                        $CSVContentObj.SourceURL = $entry."Source URL"
                        $CSVContentObj.RectifiedName = $entry."Rectified Name"
                        #Adding custom PS object in the arrary    
                        $CSVContentList += $CSVContentObj
                    }
                }
                else
                {
                    Write-Host -ForegroundColor Yellow "File don't have any content"
                }
            }
            if($CSVContentList -ne $null)
            {
                #Getting current script execution location
                $CurrentLoc = Get-Location
                if($MergedFileName.IndexOf(".csv") > 0)
                {
                    $csvPath = "$CurrentLoc\$MergedFileName"
                }
                else
                {
                    $csvPath = "$CurrentLoc\$MergedFileName.csv"
                }
                #Exporting the content as csv file
                $CSVContentList | Export-Csv -Path $csvPath
                Write-Host -ForegroundColor Green "Files merged successfully and exported at "$csvPath     
            }

        }
        catch
        {
            Write-Host -ForegroundColor Red "Error:"$_.Exception.ToString()
        }
    }
    End
    {
    }
}


$userPath = Read-Host "Enter path where all csv files are stored"
Write-Host
$userFilter = Read-Host "Enter filter expression to filter the files to be merged (optional). Press enter if none"
Write-Host 
$userFileName = Read-Host "Enter name of the file where merged content would be written" 

if($userFilter -ne $null -and $userFilter -ne "")
{
    Merge-CSVFiles -Path $userPath -Filter $userFilter -MergedFileName $userFileName
}
else
{
    Merge-CSVFiles -Path $userPath -MergedFileName $userFileName
}
#Examples: Merge-CSVFiles -Path "C:\Users\Tstmos\Desktop\Merge" -Filter "Name Results *.csv" -MergedFileName "MyMergedFile1"
#Examples: Merge-CSVFiles -Path "C:\Users\Tstmos\Desktop\Merge" -Filter "Size *.csv" -MergedFileName "MyMergedFile2"
