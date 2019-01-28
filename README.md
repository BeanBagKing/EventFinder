# EventFinder has been superseded! 
Check out the new version: https://github.com/BeanBagKing/EventFinder2

EventFinder 2.0 was re-written in C# to avoid the massive number of PowerShell logs. I'm leaving this version for reference and as an alternative, but I highly suggest checking out the new version.

### EventFinder
Finds event logs between two time points. Useful for support/malware analysis.

### About
This program allows you to mark (or set) a beginning and end time period, then grabs all
events between those periods. It dumps these to a sorted CSV on the desktop. 

This program will not read certain logs (Security, Sysmon) without Administrator privileges.

This is EXTREAMLY noisy in PowerShell logs due to nested loops. I don't think this is avoidable
so be careful not to push legitimate logs you need off the end of the stack. 

### Example Use Cases
Support teams can mark a begin time, and perform an action that may cause a crash or
other problem on a workstation. Then mark the end and dump the logs to determin what might
have happened.

A security analyst could use this to run malware (in a contained environment) and determin
via logs what this malware did and in what order, which may be used to create IOC's

### Detailed Usage
* Open a PowerShell window as Administrator
* Run the program (e.g. .\EventFinder.ps1)
* In the resulting window, click Start Time button
* Perform whatever action that you want to see events for
* Click the End Time button -  At this point (or any other), the time periods can be manually adjusted
* Click Find Events
* Wait while the program generates a CSV of found events on the current desktop - File name will be "Logs_Runtime_\<datestamp>_\<runtime>.csv"

### Screenshot Time!
![EventFinder](https://raw.githubusercontent.com/BeanBagKing/EventFinder/master/EventFinder.png)
