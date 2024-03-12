#Must use PowerShell 7.x to avoid long path/filename output issues
#Change the FOUR variables below to match your file/folder paths
$case_folder = "c:\cases"
$casename = 'demo'
$baseline_folder_name = 'baseline'
$target_folder_name = 'target'

$baseline_compressed_data = "$case_folder\$casename\$baseline_folder_name"
$target_compressed_data = "$case_folder\$casename\$target_folder_name"
Expand-Archive -path $baseline_compressed_data\*.zip -DestinationPath $baseline_compressed_data -Force
Expand-Archive -path $target_compressed_data\*.zip -DestinationPath $target_compressed_data -Force

#Creates "output" folder
$output_destination_directory = "$case_folder\$casename\output"
New-Item -Path $case_folder\$casename\output -ItemType Directory

#Copies baseline "results" to output folder
Copy-Item $baseline_compressed_data\results\*Netstat.csv  $output_destination_directory\$baseline_folder_name'-netstat.csv'
Copy-Item $baseline_compressed_data\results\*StartupItems.csv  $output_destination_directory\$baseline_folder_name'-startup.csv'
Copy-Item $baseline_compressed_data\results\*pslist.csv  $output_destination_directory\$baseline_folder_name'-pslist.csv'
Copy-Item $baseline_compressed_data\results\*Services.csv  $output_destination_directory\$baseline_folder_name'-services.csv'
Copy-Item $baseline_compressed_data\results\*Scheduler*.csv  $output_destination_directory\$baseline_folder_name'-tasks.csv'
Copy-Item $baseline_compressed_data\results\*DNSCache.csv  $output_destination_directory\$baseline_folder_name'-dns.csv'
#Copies target "results" to output folder
Copy-Item $target_compressed_data\results\*Netstat.csv  $output_destination_directory\$target_folder_name'-netstat.csv'
Copy-Item $target_compressed_data\results\*StartupItems.csv  $output_destination_directory\$target_folder_name'-startup.csv'
Copy-Item $target_compressed_data\results\*pslist.csv  $output_destination_directory\$target_folder_name'-pslist.csv'
Copy-Item $target_compressed_data\results\*Services.csv  $output_destination_directory\$target_folder_name'-services.csv'
Copy-Item $target_compressed_data\results\*Scheduler*.csv  $output_destination_directory\$target_folder_name'-tasks.csv'
Copy-Item $target_compressed_data\results\*DNSCache.csv  $output_destination_directory\$target_folder_name'-dns.csv'
#Combines target and baseline output into a single workbook; if prompted to save in Excel, click "don't save"
(get-childitem -Directory $output_destination_directory).name | ForEach-Object {
    $ExcelObject=New-Object -ComObject excel.application
    #$ExcelObject.visible=$true
    $ExcelObject.visible=$false
    $ExcelObject.DisplayAlerts=$false
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
