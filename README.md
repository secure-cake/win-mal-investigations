# Windows Malware Investigations
Scripts and notes for performing Windows malware investigations via differential analysis using PowerShell, Velociraptor and Excel!

Context = You've had an alert/event and need to investigate possible or confirmed malware detonation on a Windows endpoint. 
Input = Forensic artifacts related to common malware behaviors (initial access, actions on objective, network communications, detection evasion, persistence)
Output = Actionable Intelligence! We're looking for "clues" that we can use to identify "attack extents"* (all unauthorized activuty within the environment)

Tasks:
1.  Select artifacts
2.  Acquire artifacts from "baseline" system (known-good, representative sample)
3.  Acquire artifacts from "target" system (system we are investigating)
4.  Parse artifacts
5.  Perform differential analysis to identity "unusual/anomalous" activity

