# Hash_copy_all_files_and_folders
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
