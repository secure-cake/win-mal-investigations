# Windows Malware Investigations
Scripts and notes for performing Windows malware investigations via differential analysis using PowerShell, Velociraptor and Excel!

**Context** = You've had an alert/event and need to investigate possible or confirmed malware detonation on a Windows endpoint.

**Input** = Forensic artifacts related to common malware behaviors (initial access, actions on objective, network communications, detection evasion, persistence)

**Output** = Actionable Intelligence! We're looking for "clues" that we can use to identify "attack extents"* (all unauthorized activuty within the environment)

_Tasks_:
1.  Select artifacts
2.  Acquire artifacts from "baseline" system (known-good, representative sample)
3.  Acquire artifacts from "target" system (system we are investigating)
4.  Parse artifacts
5.  Perform differential analysis to identity "unusual/anomalous" activity
----------------
**Select Artifacts**:

Based on recent analysis of the top several malware families and common behaviors and indicators, we'll acquire the following Windows artifacts:
1.  Disk: Master File Table (MFT)
2.  Network Connections: Netstat, DNS Cache
3.  Memory/Running Processes: pslist
4.  Persistence Mechanisms: Services, Scheduled Tasks, Startup Items

NOTE: In the "Acquire Artifacts" section belowe, we'll grab a few other, small/lightweight "may be useful outside of differential analysis" artifacts as well!

-----------------

**Acquire Artifacts**:

We'll use a Velociraptor Offline Collector to acquire artifacts from our baseline system (known-good, representative sample) and our target system (the system we are investigating). 

_Velociraptor Offline Collector Configuration_
Download and execute current, stable version of Velocraptor: 
-  Velociraptor (download): https://github.com/Velocidex/velociraptor/releases (tested with 0.7.1)
-  Velociraptor Documentation: https://docs.velociraptor.app/blog/

>velociraptor-v0.7.1-1-windows-amd64.exe gui

Click on "Server Artifacts" (left-hand flyout menu), "Build Offline Collector" (paper airplane icon), then search and "click to add" artifacts:
 - Windows.Network.NetstatEnriched
 - Windows.System.Pslist
 - Windows.KapeFiles.Targets
 - Windows.System.TaskScheduler
 - Windows.System.Services
 - Windows.System.StartupItems
 - Windows.System.DNSCache

Configure "Parameters:"
 - Windows.Network.NetstatEnriched:
   -  Change ProcessNameRegex to = “.”
 - Windows.System.Pslist:
   - accept defaults
 - Windows.KapeFiles.Targets: selec the following artifacts (NOTE: You can use teh "filter artifact parameter name" search box to search!)
   - _MFT
   - Antivirus
   - EventLogs
   - PowerShellConsole
   - PowerShellTranscripts
 - Windows.System.TaskScheduler:
   - Check "AlsoUpload"
 - Windows.System.Services
   - accept defaults
 - Windows.System.StartupItems:
   - accept defaults
 - Windows.System.DNSCache:
   - accept defaults

Configure "Collection:" (ZIP or S3 Upload)
 - Collection Type: **ZIP**
     - Output Format: CSV and JSON
     - Pause for Prompt: Check
     - Filename Format: (I usually clear "Collection" for brevity, you can put in "win-mal-" to identify collection type)
-  Collection Type: **AWS Bucket** (See "AWS Collection Upload Configuration" NOTES below)
   -  S3 Bucket: your-triage-upload-bucket-name (no "/")
   -  Credentials Key: copy/paste your AWS IAM Access Key here (remove any trailing space!)
   -  Credentials Secret: copy/paste your AWS IAM Secret Key here (remove any trailing space!)
   -  Region: us-east-1 (edit according to your desired region)
   -  File Name Prefix: your-case-specific-folder-name/ (include trailing "/")
   -  Output Format: CSV and JSON
   -  Pause for Prompt: Check
-  Launch/Download Collector:
   -  Click "Server.Utils.CreateCollector, Uploaded Files," then click "Collector_velociraptor-vn.n.n-windows-amd64.exe"
   -  If you receive browser warnings, "keep" and download
   -  Rename collector descriptively, eg "win-mal-no-upload-collector-win-x64.exe"
  **NOTE:** I have created and shared a collector in this repo, with the above configuration, suitable for your use/testing (win-mal-no-upload-collector-v0.7.1-1-windows-amd64.zip)!

Next, we'll need to copy the collector executable to our "target" and "baseline" systems, "run as admin" to create the ZIP archive of Windows Artifacts, then move the ZIP files to our Analysis Workstation.

NOTE: Ideally, the "baseline" collection can and should be run proactively, before an alert/event/incident requiring investigation occurs. 

**Remote Console** - If you have a "remote console" opition via EDR or similar, with the ability to send/receive files, this can be a FANTASTIC way to copy the exe to the "target" endpoint, execute the collector, then retrieve the ZIP file safely/securely. 

------------------------
**Parse Artifacts**:

Although we gathered some artifacts that generally require parsing for review/analysis (MFT, EVTX), the "Win Mal Investigation" primary artifacts don't require parsing, though some formatting is helpful. We'll use Excel to combine our "tareget" and "baseline" endpoint output into a single Excel workbook, to format our data, and to perform "differential" analysis via Contional Formatting, "highlighting" artifact entries that exist on our "target" but NOT on our "baseline" endpoint.

We will need to stage our data and make sure the script matches our folder naming and hierarchy. In general, I follow the following directory structure:
- Separate Data Volume: eg "D:\" (separeate from the OS Volume)
- Cases Folder on Data Volume: eg "D:\cases"
- Named Case Folder under Cases: eg "D:\cases\winmal-case"
- Triage Data Folder under Case Folder: eg "D:\cases\winmal-case\winmal_data"
- Output directory for parses/formatted Case Data: eg "D:\cases\winmal-case\winmal_data\output"

Obviously do what makes sense to you, but make sure the folders/paths are set correctly in the script variables (see "WinMal_Excel.ps1" script in this repo).

Assuming you are following the aforementioned directory structure, unzip your "baseline" system collection to "D:\cases\baseline\winmal_data," then run the "WinMal_Baseline.ps1" script, which will rename and stage artifact CSV files to the "output" directory. We'll copy/paste the "output" directory into the "winmal-case" directory shortly. 
NOTE: _you don't need to create a new baseline every time you perform analysis, only if and when things change and you need to update!_

Next, unzip the "target" system collection to "D:\cases\winmal-case\winmal_data," COPY the "output" directory (not just the contents, but the entire directory) into "D:\cases\winmal-case\winmal_data\," then run the "WinMal_Excel.ps1" script 
NOTE: _you must have Excel installed on your Analysis Workstation for this to work!_

You should now have a "target-with-baseline-output.xlsx" workbook in the "output" folder!

----------------------------
**Differential Analysis**:

Last but not least, we'll perform differential analysis to identity "unusual/anomalous" activity using Excel. We'll need to create some "automations" in Excel, but you should only have to do this once on your Analysis Workstation. 

First, open the "target-with-baseline-output.xlsx" workbook in Excel. Then click "automate" on the top menu, then "new script." In the Code Editor, click the default script name, "Script" and enter a new name for the script (see below). Then copy/paste the provided script code below. Repeat x6 for each of the scripts below (sorry, but you only have to complete this process once! the scripts will automatically associate with your Excel sign-in and be available on other systems!)

_dns-diff_:
```
function main(workbook: ExcelScript.Workbook) {
    let conditionalFormatting: ExcelScript.ConditionalFormat;
    let selectedSheet = workbook.getActiveWorksheet();
    // Create custom from range A:A on selectedSheet
    conditionalFormatting = selectedSheet.getRange("A:A").addConditionalFormat(ExcelScript.ConditionalFormatType.custom);
    conditionalFormatting.getCustom().getRule().setFormula("=COUNTIF('baseline-dns'!$A$1:$A$100,A1)=0");
    conditionalFormatting.getCustom().getFormat().getFill().setColor("#ffe699");
    conditionalFormatting.setStopIfTrue(false);
    conditionalFormatting.setPriority(0);
  // Set height of row(s) at all cells on selectedSheet to 15
  selectedSheet.getRange().getFormat().setRowHeight(15);
}
```
_netstat-diff_: 
```
function main(workbook: ExcelScript.Workbook) {
	let conditionalFormatting: ExcelScript.ConditionalFormat;
	let selectedSheet = workbook.getActiveWorksheet();
	// Create custom from range C:C on selectedSheet
	conditionalFormatting = selectedSheet.getRange("C:C").addConditionalFormat(ExcelScript.ConditionalFormatType.custom);
	conditionalFormatting.getCustom().getRule().setFormula("=COUNTIF('baseline-netstat'!$C$1:$C$250,C1)=0");
	conditionalFormatting.getCustom().getFormat().getFill().setColor("#ffe699");
	conditionalFormatting.setStopIfTrue(false);
	conditionalFormatting.setPriority(0);
	// Set height of row(s) at all cells on selectedSheet to 15
	selectedSheet.getRange().getFormat().setRowHeight(15);
}
```
_pslist-diff_: 
```
function main(workbook: ExcelScript.Workbook) {
	let conditionalFormatting: ExcelScript.ConditionalFormat;
	let selectedSheet = workbook.getActiveWorksheet();
	// Create custom from range D:D on selectedSheet
	conditionalFormatting = selectedSheet.getRange("D:D").addConditionalFormat(ExcelScript.ConditionalFormatType.custom);
	conditionalFormatting.getCustom().getRule().setFormula("=COUNTIF('baseline-pslist'!$D$1:$D$250,D1)=0");
	conditionalFormatting.getCustom().getFormat().getFill().setColor("#ffe699");
	conditionalFormatting.setStopIfTrue(false);
	conditionalFormatting.setPriority(0);
	// Set height of row(s) at all cells on selectedSheet to 15
	selectedSheet.getRange().getFormat().setRowHeight(15);
}
```
_services-diff_:
```
function main(workbook: ExcelScript.Workbook) {
    let conditionalFormatting: ExcelScript.ConditionalFormat;
    let selectedSheet = workbook.getActiveWorksheet();
    // Create custom from range A:A on selectedSheet
    conditionalFormatting = selectedSheet.getRange("B:B").addConditionalFormat(ExcelScript.ConditionalFormatType.custom);
    conditionalFormatting.getCustom().getRule().setFormula("=COUNTIF('baseline-services'!$B$1:$B$300,B1)=0");
    conditionalFormatting.getCustom().getFormat().getFill().setColor("#ffe699");
    conditionalFormatting.setStopIfTrue(false);
    conditionalFormatting.setPriority(0);
  // Set height of row(s) at all cells on selectedSheet to 15
  selectedSheet.getRange().getFormat().setRowHeight(15);
  }
```
_startup-diff_:
```
function main(workbook: ExcelScript.Workbook) {
    let conditionalFormatting: ExcelScript.ConditionalFormat;
    let selectedSheet = workbook.getActiveWorksheet();
    // Create custom from range A:A on selectedSheet
    conditionalFormatting = selectedSheet.getRange("A:A").addConditionalFormat(ExcelScript.ConditionalFormatType.custom);
    conditionalFormatting.getCustom().getRule().setFormula("=COUNTIF('baseline-startup'!$A$1:$A$50,A1)=0");
    conditionalFormatting.getCustom().getFormat().getFill().setColor("#ffe699");
    conditionalFormatting.setStopIfTrue(false);
    conditionalFormatting.setPriority(0);
  // Set height of row(s) at all cells on selectedSheet to 15
  selectedSheet.getRange().getFormat().setRowHeight(15);
}
```
_tasks-diff_:
```
function main(workbook: ExcelScript.Workbook) {
    let conditionalFormatting: ExcelScript.ConditionalFormat;
    let selectedSheet = workbook.getActiveWorksheet();
    // Create custom from range A:A on selectedSheet
    conditionalFormatting = selectedSheet.getRange("A:A").addConditionalFormat(ExcelScript.ConditionalFormatType.custom);
    conditionalFormatting.getCustom().getRule().setFormula("=COUNTIF('baseline-tasks'!$A$1:$A$250,A1)=0");
    conditionalFormatting.getCustom().getFormat().getFill().setColor("#ffe699");
    conditionalFormatting.setStopIfTrue(false);
    conditionalFormatting.setPriority(0);
  // Set height of row(s) at all cells on selectedSheet to 15
  selectedSheet.getRange().getFormat().setRowHeight(15);
}
```


