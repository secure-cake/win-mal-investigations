#change four variables below for casename, target hostname, triage dir and output dir
$casename = 'wmi-case'
$target_hostname = 'RTW-Win11'
$triage_data_directory = "c:\cases\$casename\wmi_data"
$output_destination_directory = "c:\cases\$casename\output"

(get-childitem -Directory $triage_data_directory).name | ForEach-Object {
#Copies triage-collection "results" to kape_output directory for review
Copy-Item $triage_data_directory\$_\results\*Netstat.csv  $output_destination_directory\$target_hostname'-netstat.csv'
Copy-Item $triage_data_directory\$_\results\*StartupItems.csv  $output_destination_directory\$target_hostname'-startup.csv'
Copy-Item $triage_data_directory\$_\results\*pslist.csv  $output_destination_directory\$target_hostname'-pslist.csv'
Copy-Item $triage_data_directory\$_\results\*Services.csv  $output_destination_directory\$target_hostname'-services.csv'
Copy-Item $triage_data_directory\$_\results\*Scheduler*.csv  $output_destination_directory\$target_hostname'-tasks.csv'
}
#if prompted to save in Excel, click "don't save"
(get-childitem -Directory $triage_data_directory).name | ForEach-Object {
    $ExcelObject=New-Object -ComObject excel.application
    $ExcelObject.visible=$true
    $ExcelFiles=Get-ChildItem -Path $output_destination_directory -Recurse -Include *.csv, *.xls, *.xlsx

    $Workbook=$ExcelObject.Workbooks.add()
    $Worksheet=$Workbook.Sheets.Item("Sheet1")

    foreach($ExcelFile in $ExcelFiles){
 
        $Everyexcel=$ExcelObject.Workbooks.Open($ExcelFile.FullName)
        $Everysheet=$Everyexcel.sheets.item(1)
        $Everysheet.Copy($Worksheet)
    $Everyexcel.Close()
 
    }
$Workbook.SaveAs("$output_destination_directory\target-with-baseline-output.xlsx")
$ExcelObject.Quit()
}
