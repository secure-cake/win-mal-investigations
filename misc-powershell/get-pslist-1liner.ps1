#find and replace "path\to-output" with your desired path for file output
Get-Wmiobject win32_process | select name,executablepath,processid,parentprocessid,commandline | export-csv c:\path\to-output\pslist.csv -NoTypeInformation
