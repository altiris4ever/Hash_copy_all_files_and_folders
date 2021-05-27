<#

.SYNOPSIS
This Powershell script uses file hashes to compare and only copy all the missing or changed file(s) & folder(s) into the target directory from the defined source directory. 

.DESCRIPTION
This Powershell script uses file hashes to compare and only copy all the missing or changed file(s) & folder(s) into the target directory from the defined source directory.
This script is ignoring any file(s) and folder(s) if they only exist in the destination directory.
This script write everyhing to a log file.

This script accepts 4 parameters.
 -source   The name of source directory. c:\temp\test
 -destination The name of destination directory.  c:\temp\test2
 -writeoutput $true og $false : output activity to console $true
 -logfile The name and destination of the logfile, like c:\temp\logfile.log

.EXAMPLE
.\scriptname.ps1 -source -destination -logfile -writeoutput $true
scriptname.ps1 -source c:\temp\1 -destination c:\temp\2 -logfile c:\temp\logefile.log -writeoutput $true
#Examplescript 1: For uploading Teams backgroundfiles into each users "env:USERPROFILE"\AppData\Roaming\Microsoft\Teams\Backgrounds\Uploads" folder from a fileshare. 
#if this script is signed it could be run alongside envionments who has Applocker activated, even by the std user account on logon, or by SCCM,a scheduled task or something similar like that.
scriptname.ps1 -source \\fileshare\teams\ -destination $env:USERPROFILE"\AppData\Roaming\Microsoft\Teams\Backgrounds\Uploads" -logfile $env:USERPROFILE"\AppData\Roaming\Microsoft\Teams\Backgrounds\Background_copy.log"
#Examplescript 2: For downloading notepad ++ plugins from a fileshare into %programfiles%\notepad++\plugins folder. MUST RUN THIS WITH admin right since it's a protected system folder.
scriptname.ps1 -source \\fileshare\notepad++\plugin\ -destination "C:\Program Files\Notepad++\plugins" -logfile "C:\Program Files\Notepad++\plugins\Plugin_copy.log"

.NOTES
Author: https://twitter.com/ArneJ666 

.TODO
Make som more advanced inputcheck on -source -destination and -logfile. Only standard errorchecking.
Better formating of time used in logfile.

.LINK


#>
param (
       #[Parameter(Mandatory = $false)]
       [ValidateScript({ Test-Path $_ })]
       [Parameter(Mandatory=$true)] 
       [string]$source = '',
       [Parameter(Mandatory=$true)]
       #[ValidateScript({ Test-Path $destination })]
       [string]$destination = '',
       [Parameter(Mandatory=$true)]
       #[ValidateScript({ Test-Path $logfile })]
       [string]$logfile = '',
       [Parameter(Mandatory=$false)]
       [bool]$show = $false
)


if ($logfile -eq "") {
       write-host "Logfile needs to be defined by using -destination Driveletter:\path\logfile.log"
       exit
}
if (!(Test-Path $logfile)) {      
       $b = New-Item $logfile -Itemtype file -Force -EA 0
}


if ($destination -eq "") {
       write-host "Destination needs to be defined by using -destination Driveletter:\path"
       exit
}
if (!(Test-Path $destination)) {
       $a = New-Item $destination -Itemtype directory -Force -EA 0
}




$log = @()
$sourceFiles = @();
$sourceFiles += (get-childitem -path $source -recurse | Select-Object FullName).Fullname
$stopwatch = get-Date -Format 'dd.MM.yyyy HH:mm:ss'
foreach ($sourceFile in $sourceFiles) {
       [string]$destFile = $sourceFile.ToLower().Replace($source.ToLower(), $destination.ToLower())
       [bool]$isFile = (Test-Path -Path $sourceFile -PathType 'Leaf')
       if (Test-Path -Path $destFile) {
             if ($isFile) {
                    if ((Get-FileHash -Path $sourceFile).Hash -ne (Get-FileHash -Path $destFile).Hash) {
                           $a = Copy-Item -Path $sourceFile -Destination $destFile
                           $log += "Changed File..: " + $destFile
                           #Write-Host "FileHash:" $sourceFile  '->' $destFile
                    }
             }
       } else {
             if ($isFile) {
                    $a = Copy-Item -Path $sourceFile -Destination $destFile
                    $log += "Adding File...: " + $destFile
                    #Write-Host $sourceFile  ' -> '  $destFile
             } else {
                    $a = New-Item $destFile -Itemtype directory -Force -EA 0
                    $log += "New Folder....: " + $destFile
                    #Write-Host "Missing folder:" $sourceFile '->' $destFile
             }
       }
}
$time = get-Date -Format 'dd.MM.yyyy HH:mm:ss.fff'

if ($log.Count -gt 0) {
       $log2 = @(("SourcePath: " + $source))
       $log2 += "---------------------------------------------------------------------------------------"
       $log2 += $log
       $log2 += "---------------------------------------------------------------------------------------"
       $log2 += "Time used: Hour:min:sec:fractions: " + (New-TimeSpan -Start $stopwatch -End $time).ToString("hh\:mm\:ss\.fff")
       $log2 += "======================================================================================="
       if (!(Test-Path $logfile)) { New-Item $logfile -Itemtype file -Force -EA 0}
       Out-File -FilePath $logfile -InputObject $log2 -Force -Encoding unicode
       if ($show) {
             $log2 | ForEach-Object{
                    ForEach-Object{ Write-Host $_ }
             }
       }
} else {
       if ($show) {
             Write-host "Time used: Hour:min:sec:fractions: "(New-TimeSpan -Start $stopwatch -End $time).ToString("hh\:mm\:ss\.fff")
       }
}
