<#
.Synopsis
    A small powershell program to make finding events related to an action easier.
.DESCRIPTION
    This program grabs all WIndows Event Logs between two time periods. The program requires Administrator
    rights to view certain event logs (e.g. System and Sysmon). It will warn you if it does not believe it has
    access to these logs. Hit Start, perform the action, and hit End to mark the relevant time periods. Then press 
    Find Events. The program will drop a CSV on your desktop containing all relevent events.
.EXAMPLE
    Run the GUI, press the buttons, recieve the file.  
.INPUTS
 
.OUTPUTS
 
.NOTES
    Notable limitations: 
    - This script is EXTREAMLY NOISY and may overwrite events in various Powershell Logs.
    - Additionally, this may be of questionable benifit when examining maliciuos activity as the time granularity only
      resolves down to the second.
    - The Script does not -require- administrative privileges to read most logs. However, it does require it to read all logs.
.FUNCTIONALITY
    Get Logs
.Author
    Mike Peterson (peterm30@erau.edu) 1/24/2018 - Templated from LAPS Powershell program, Dalker 07/03/2016
#>
 
# ============================================================================================================
# ==== Variables =============================================================================================
# ============================================================================================================
 
# App Name.
$AppNAME = "FindEvents"
# Version.
$Ver = "1.1"
    # v 1.0 -- Initial release (24 Jan 2019)
    # v 1.1 -- Codename "I should test my code before initial release" (25 Jan 2019)
    #       - Fixed a copy/paste error that resulted in no output
    #       - Fixed a logic error that didn't remove unnecessary (self-generated) log lines
    #       - Commented out debugging code



# Set some global variables
$DesktopPath = [Environment]::GetFolderPath("Desktop")
 
if ((Get-WinEvent -ListLog * -ErrorAction SilentlyContinue).LogName -match '^Security$') 
{
    $AdminCheck = "Security log found, you are likely administrator!"
} else {
    $AdminCheck = "Unable to read Security log, are you administrator?"
}
 
# ============================================================================================================
# ==== Create GUI ============================================================================================
# ============================================================================================================
 
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
 
#==< GUI >=======================================================================
$GUI = New-Object System.Windows.Forms.Form
$GUI.ClientSize = New-Object System.Drawing.Size(278, 157)
$GUI.FormBorderStyle = 'Sizable'
#$GUI.MaximizeBox = $false
$GUI.Text = "$AppNAME - v$Ver"
#==< EventRangeGroupBox >=========================================================
$EventRangeGroupBox = New-Object System.Windows.Forms.GroupBox
$EventRangeGroupBox.Font = New-Object System.Drawing.Font("Tahoma", 8.25, [System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel, ([System.Byte](0)))
$EventRangeGroupBox.Location = New-Object System.Drawing.Point(12, 2)
$EventRangeGroupBox.Size = New-Object System.Drawing.Size(250, 79)
$EventRangeGroupBox.TabStop = $false
$EventRangeGroupBox.Text = "Event Range"
#==< StartDateButton >==============================================================
$StartButton = New-Object System.Windows.Forms.Button
$StartButton.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel, ([System.Byte](0)))
$StartButton.Location = New-Object System.Drawing.Point(19, 20)
$StartButton.Size = New-Object System.Drawing.Size(70, 21)
$StartButton.TabIndex = 3
$StartButton.Text = "Start Time"
$StartButton.UseVisualStyleBackColor = $true
$StartButton.Add_Click({
    StartButtonClick
    ;})
#==< EndDateButton >==============================================================
$EndButton = New-Object System.Windows.Forms.Button
$EndButton.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel, ([System.Byte](0)))
$EndButton.Location = New-Object System.Drawing.Point(19, 50)
$EndButton.Size = New-Object System.Drawing.Size(70, 21)
$EndButton.TabIndex = 3
$EndButton.Text = "End Time"
$EndButton.UseVisualStyleBackColor = $true
$EndButton.Add_Click({
    EndButtonClick
    ;})
#==< StartDateInput >=============================================================
$StartInput = New-Object System.Windows.Forms.TextBox
$StartInput.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel, ([System.Byte](0)))
$StartInput.Location = New-Object System.Drawing.Point(110, 20)
$StartInput.Size = New-Object System.Drawing.Size(145, 20)
$StartInput.TabIndex = 0
$StartInput.Text = ""
#==< EndDateInput >=============================================================
$EndInput = New-Object System.Windows.Forms.TextBox
$EndInput.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel, ([System.Byte](0)))
$EndInput.Location = New-Object System.Drawing.Point(110, 50)
$EndInput.Size = New-Object System.Drawing.Size(145, 20)
$EndInput.TabIndex = 1
$StartInput.Text = ""
#==< FindEventsButton >==============================================================
$FindEventsButton = New-Object System.Windows.Forms.Button
$FindEventsButton.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel, ([System.Byte](0)))
$FindEventsButton.Location = New-Object System.Drawing.Point(99, 90)
$FindEventsButton.Size = New-Object System.Drawing.Size(80, 21)
$FindEventsButton.TabIndex = 3
$FindEventsButton.Text = "Find Events"
$FindEventsButton.UseVisualStyleBackColor = $true
$FindEventsButton.Add_Click({
    FindEventsClick
    ;})
#==< StatusGroupBox >============================================================
$StatusGroupBox = New-Object System.Windows.Forms.GroupBox
$StatusGroupBox.Location = New-Object System.Drawing.Point(3, 116) #116 from 245
$StatusGroupBox.Size = New-Object System.Drawing.Size(272, 40)
$StatusGroupBox.TabStop = $True
$StatusGroupBox.Text = "Status"
#==< StatusBoxOutput >===========================================================
$StatusBoxOutput = New-Object System.Windows.Forms.Label
$StatusBoxOutput.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$StatusBoxOutput.Font = New-Object System.Drawing.Font("Tahoma", 8.25, [System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel, ([System.Byte](0)))
$StatusBoxOutput.Location = New-Object System.Drawing.Point(6, 133) # 133 from 262
$StatusBoxOutput.Size = New-Object System.Drawing.Size(266, 14)
$StatusBoxOutput.Text = $AdminCheck
$StatusBoxOutput.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$StatusBoxOutput.BackColor = [System.Drawing.SystemColors]::Menu
$StatusBoxOutput.ForeColor = "Black"
#==< Create GUI controls >=======================================================
 
$GUI.Controls.Add($StartButton)
$GUI.Controls.Add($EndButton)
$GUI.Controls.Add($StartInput)
$GUI.Controls.Add($EndInput)
$GUI.Controls.Add($EventRangeGroupBox)
$GUI.Controls.Add($FindEventsButton)
$GUI.Controls.Add($StatusBoxOutput)
$GUI.Controls.Add($StatusGroupBox)
 
# ============================================================================================================
# ==== Functions =============================================================================================
# ============================================================================================================
 
function Main { # Launch GUI.
       [System.Windows.Forms.Application]::EnableVisualStyles()
       [System.Windows.Forms.Application]::Run($GUI)
    } # <== Main
 
function StartButtonClick($object) { # Search Button clicked.
    # Disable Search button
    $StartButton.Enabled = $false # Disable Search button
 
    # Set some options
    $CurrentTime = (Get-Date).ToString()
    $StartInput.Text = $CurrentTime
   
    $StartButton.Enabled = $true # Enable Search button
    } # <== SearchButtonClick
 
function EndButtonClick($object) { # Search Button clicked.
    # Disable Search button
    $EndButton.Enabled = $false # Disable Search button
 
    # Set some options
    $CurrentTime = (Get-Date).ToString()
    $EndInput.Text = $CurrentTime
   
    $EndButton.Enabled = $true # Enable Search button
    } # <== SearchButtonClick
 
function FindEventsClick($object) { # Search Button clicked.
    # Disable Search button
    $FindEventsButton.Enabled = $false # Disable Search button
 
    # Run this as administrator or Get-WinEvent will -not- enumerate administratively prohibitited logs (e.g. Security, Sysmon)
    $eventLogs = (Get-WinEvent -ListLog * -ErrorAction SilentlyContinue).LogName
    $StartTime = $StartInput.Text
    $EndTime = $EndInput.Text
 
    #Write-Host $StartTime
    #Write-Host $EndTime
 
    foreach ($eventLog in $eventLogs) {
        try
        {
            Get-WinEvent -FilterHashtable @{LogName=$eventLog;StartTime=$StartTime;EndTime=$EndTime} -ErrorAction Stop | Export-CSV $DesktopPath\tmp.csv -Append -NoTypeInformation
            #Get-WinEvent -FilterHashtable @{LogName=$eventLog;StartTime=([datetime]'1/22/2019 12:21:00 pm');EndTime=([datetime]'1/22/2019 12:33:00 pm')} -ErrorAction Stop | ConvertTo-Json | Out-File $DesktopPath\yrmp.json -Append
        }
        catch [Exception]
        {
                if ($_.Exception -match "No events were found that match the specified selection criteria")
                {
                    #Write-Host "No events found";
                }
        }
    }
    # Our script is rather noisy in certain logs, so strip out everything related to our run. 
    # Why do we have to search for %s number of items? Beecause Microsoft logs have all the consistaency of a herd of cats stampeeding across a keyboard 
    $PathSearch1 = "*ScriptName=$PSCommandPath*"
    $PathSearch2 = "*Script Name = $PSCommandPath*"
    $PathSearch3 = "*Path: $PSCommandPath*"
    $PathSearch4 = "*CommandPath=$PSCommandPath*"
    $FileCreateTime = Get-Date -UFormat "%Y%m%d_%H%M%S"
    Import-Csv $DesktopPath\tmp.csv | where {($_.Message -notlike $PathSearch1) -and ($_.Message -notlike $PathSearch2) -and ($_.Message -notlike $PathSearch3) -and ($_.Message -notlike $PathSearch4)} | Export-Csv $DesktopPath\tmp2.csv -NoTypeInformation
    Remove-Item $DesktopPath\tmp.csv
    Import-Csv $DesktopPath\tmp2.csv | sort username -Descending | Export-Csv -Path $DesktopPath\Logs_Runtime_$fileCreateTime.csv -NoTypeInformation
    Remove-Item $DesktopPath\tmp2.csv
    $FindEventsButton.Enabled = $true # Enable Search button
    } # <== SearchButtonClick
 
# ============================================================================================================
# ==== Script ================================================================================================
# ============================================================================================================
 
Main # Launch the GUI 
