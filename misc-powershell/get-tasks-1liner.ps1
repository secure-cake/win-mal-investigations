#find and replace "path\to-output" with your desired path for file output
schtasks /query /V /FO csv | convertfrom-csv | where taskname -ne "TaskName" | select hostname,taskname,'next run time',status,'logon mode','last run time', author,'task to run','start in',comment,'scheduled task state','run as user' | export-csv c:\path\to-output\scheduled-tasks.csv -NoTypeInformation
