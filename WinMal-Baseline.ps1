#change four variables below for casename, target hostname, triage dir and output dir
$casename = 'baseline'
$target_hostname = 'baseline'
$triage_data_directory = "c:\cases\$casename\winmal_data"
$output_destination_directory = "c:\cases\$casename\output"
New-Item -Path c:\cases\$casename\output -ItemType Directory

(get-childitem -Directory $triage_data_directory).name | ForEach-Object {
#Copies triage-collection "results" to output directory for review
Copy-Item $triage_data_directory\$_\results\*Netstat.csv  $output_destination_directory\$target_hostname'-netstat.csv'
Copy-Item $triage_data_directory\$_\results\*StartupItems.csv  $output_destination_directory\$target_hostname'-startup.csv'
Copy-Item $triage_data_directory\$_\results\*pslist.csv  $output_destination_directory\$target_hostname'-pslist.csv'
Copy-Item $triage_data_directory\$_\results\*Services.csv  $output_destination_directory\$target_hostname'-services.csv'
Copy-Item $triage_data_directory\$_\results\*Scheduler*.csv  $output_destination_directory\$target_hostname'-tasks.csv'
Copy-Item $triage_data_directory\$_\results\*DNSCache.csv  $output_destination_directory\$target_hostname'-dns.csv'
}
