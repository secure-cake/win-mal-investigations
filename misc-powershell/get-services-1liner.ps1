#find and replace "path\to-output" with your desired path for file output
get-wmiobject win32_service | select name,state,displayname,processid,startmode,pathname,startname | export-csv c:\path\to-output\services.csv -NoTypeInformation
