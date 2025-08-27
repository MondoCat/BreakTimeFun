<#
.SYNOPSIS
A stable PowerShell script to monitor a running application and display periodic break reminders.

.DESCRIPTION
This script uses a state machine and a single UI timer to reliably manage pop-ups without flickering.
It monitors a specified application and, after a set time, shows a dialog with snooze and reset options.

.NOTES
Author: Gemini
Last Modified: 2024-08-27
Version: 2.7
- Changed the initial time limit configuration to be in minutes (`TimeLimitMinutes`) instead of seconds for consistency.
#>

# --- CONFIGURATION ---
$AppName = "factorio.exe"       # The Windows process name of the app (e.g., "factorio.exe")
$TimeLimitMinutes = 60          # Wait this long for the FIRST pop-up (in minutes)
$PopupIntervalMinutes = 1       # Interval for recurring pop-ups (in minutes)
$SnoozeSeconds = 30             # Snooze duration in seconds
$PopupTimeoutSeconds = 10       # How many seconds the pop-up stays on screen before timing out
$StartHour = 17                 # Start monitoring at 5 PM (24-hour format)
$StopHour = 23                  # Stop monitoring at 11 PM (24-hour format)
# ------------------------------------

# --- SCRIPT INITIALIZATION ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Calculate time values in seconds from the configured minutes
$TimeLimitSeconds = $TimeLimitMinutes * 60

# --- STATE MANAGEMENT ---
# This object holds the current state of the script.
$scriptState = [PSCustomObject]@{
    State                 = 'Idle' # Can be: Idle, Monitoring, Snoozed, ShowingPopup, SteppedAway
    AppRunning            = $false
    FirstSeenTimestamp    = 0
    NextPopupTimestamp    = 0
    ProcessName           = $AppName.Replace(".exe", "")
    TimeLimitSeconds      = $TimeLimitSeconds
    PopupIntervalSeconds  = $PopupIntervalMinutes * 60
}

# --- UI HELPER FUNCTIONS ---

# This function creates the main interactive pop-up.
function Show-MainPopup {
    # Don't show if another pop-up is already active.
    if ($scriptState.State -eq 'ShowingPopup') { return }
    $scriptState.State = 'ShowingPopup'

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Break Time Fun"
    $form.Width = 450
    $form.Height = 220
    $form.StartPosition = 'CenterScreen'
    $form.FormBorderStyle = 'FixedDialog'
    $form.TopMost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "You have been running `"$($scriptState.ProcessName)`" for a while.`n`nTime for a break? ♥ :)"
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $label.Dock = 'Fill'
    $label.TextAlign = 'MiddleCenter'
    $form.Controls.Add($label)

    $buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttonPanel.Dock = 'Bottom'
    $buttonPanel.Height = 50
    $buttonPanel.FlowDirection = 'RightToLeft'
    $form.Controls.Add($buttonPanel)

    $buttonStepAway = New-Object System.Windows.Forms.Button
    $buttonStepAway.Text = "I'm stepping away!"
    $buttonStepAway.Size = New-Object System.Drawing.Size(120, 40)
    $buttonStepAway.DialogResult = 'Yes'
    $buttonPanel.Controls.Add($buttonStepAway)

    $buttonSnooze = New-Object System.Windows.Forms.Button
    $buttonSnooze.Text = "Snooze $($SnoozeSeconds)s"
    $buttonSnooze.Size = New-Object System.Drawing.Size(100, 40)
    $buttonSnooze.DialogResult = 'Retry'
    $buttonPanel.Controls.Add($buttonSnooze)

    $buttonNo = New-Object System.Windows.Forms.Button
    $buttonNo.Text = "No"
    $buttonNo.Size = New-Object System.Drawing.Size(100, 40)
    $buttonNo.DialogResult = 'No'
    $buttonPanel.Controls.Add($buttonNo)

    $timeoutTimer = New-Object System.Windows.Forms.Timer
    $timeoutTimer.Interval = $PopupTimeoutSeconds * 1000
    $timeoutAction = { if ($form.Visible) { $form.Close() } }
    $timeoutTimer.Add_Tick($timeoutAction)
    $form.Add_Shown({ $timeoutTimer.Start() })

    $choice = $form.ShowDialog()

    $timeoutTimer.Stop()
    $timeoutTimer.Remove_Tick($timeoutAction)
    $timeoutTimer.Dispose()
    $form.Dispose()

    # Process the user's choice and update the state.
    switch ($choice) {
        'No' {
            Show-InfoPopup -Message "That is the wrong answer... :("
            $scriptState.State = 'Monitoring'
            $scriptState.NextPopupTimestamp = (Get-Date -UFormat %s) # Trigger next pop-up immediately.
        }
        'Retry' { # Snooze
            Show-InfoPopup -Message "Giving you a little more time. Hurry up!"
            $scriptState.State = 'Snoozed'
            $scriptState.NextPopupTimestamp = [int64](Get-Date -UFormat %s) + $SnoozeSeconds
        }
        'Yes' { # Stepping away
            $scriptState.State = 'SteppedAway'
            
            Write-Host "User is stepping away. Displaying repeating thank you message."
            $startTime = [int64](Get-Date -UFormat %s)
            
            # This loop will continue as long as the app is running, for up to 3 minutes.
            while ($true) {
                $appProcess = Get-Process -Name $scriptState.ProcessName -ErrorAction SilentlyContinue
                $elapsed = [int64](Get-Date -UFormat %s) - $startTime

                # Break the loop if the app closes or 3 minutes have passed.
                if (-not $appProcess -or $elapsed -ge 180) {
                    if (-not $appProcess) { Write-Host "$AppName closed." }
                    else { Write-Host "'Thank you' message timed out." }
                    break
                }
                
                # Show the pop-up. This function waits for the timeout before returning.
                Show-InfoPopup -Message "♡❤︎♥︎ Thank You ♥︎❤︎♡" -TimeoutSeconds 3
            }

            # Reset the main timer completely.
            $scriptState.State = 'Idle'
            $scriptState.FirstSeenTimestamp = 0
        }
        default { # Timed out
            Write-Host "Pop-up timed out. Re-issuing in 3 seconds."
            $scriptState.State = 'Snoozed' # Use snooze state for a short delay.
            $scriptState.NextPopupTimestamp = (Get-Date -UFormat %s) + 3
        }
    }
}

# Shows a simple, non-interactive message box.
function Show-InfoPopup {
    param([string]$Message, [int]$TimeoutSeconds = 1)
    $infoForm = New-Object System.Windows.Forms.Form
    $infoForm.Text = "Break Time Fun"
    $infoForm.ControlBox = $false
    $infoForm.StartPosition = 'CenterScreen'
    $infoForm.Width = 400
    $infoForm.Height = 150
    $infoForm.FormBorderStyle = 'FixedDialog'
    $infoForm.TopMost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    $label.Dock = 'Fill'
    $label.TextAlign = 'MiddleCenter'
    $infoForm.Controls.Add($label)

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = $TimeoutSeconds * 1000
    $onTick = { if ($infoForm.Visible) { $infoForm.Close() } }
    $timer.Add_Tick($onTick)
    $infoForm.Add_Shown({ $timer.Start() })

    $infoForm.ShowDialog() | Out-Null

    # Clean up timer resources to prevent the null expression error
    $timer.Stop()
    $timer.Remove_Tick($onTick)
    $timer.Dispose()
    $infoForm.Dispose()
}

# --- MAIN LOGIC TIMER ---
$mainTimer = New-Object System.Windows.Forms.Timer
$mainTimer.Interval = 1000 # Check the state every second.

$mainTimer.Add_Tick({
    $currentTimestamp = [int64](Get-Date -UFormat %s)
    $currentHour = (Get-Date).Hour

    # Check if we are within the allowed monitoring hours.
    if ($currentHour -lt $StartHour -or $currentHour -ge $StopHour) {
        $scriptState.State = 'Idle'
        $scriptState.FirstSeenTimestamp = 0
        $scriptState.AppRunning = $false
        return
    }

    # Check if the target application is running.
    $process = Get-Process -Name $scriptState.ProcessName -ErrorAction SilentlyContinue
    if ($process) {
        if (-not $scriptState.AppRunning) {
            Write-Host "Detected '$AppName'. Starting timer."
            $scriptState.AppRunning = $true
            $scriptState.FirstSeenTimestamp = $currentTimestamp
            $scriptState.NextPopupTimestamp = $currentTimestamp + $scriptState.TimeLimitSeconds
            $scriptState.State = 'Monitoring'
        }
    }
    else {
        if ($scriptState.AppRunning) {
            Write-Host "$AppName is no longer running. Resetting."
            $scriptState.AppRunning = $false
            $scriptState.State = 'Idle'
            $scriptState.FirstSeenTimestamp = 0
        }
        return # Don't do anything else if the app isn't running.
    }

    # --- State-based Actions ---
    if ($scriptState.State -in @('Monitoring', 'Snoozed')) {
        if ($currentTimestamp -ge $scriptState.NextPopupTimestamp) {
            Show-MainPopup
        }
    }
})

# --- SCRIPT START ---
Write-Host "Monitoring '$AppName'. Pop-ups will appear between ${StartHour}:00 and ${StopHour}:00."
$mainTimer.Start()

# This keeps the script running. Closing the PowerShell window will stop it.
$dummyForm = New-Object System.Windows.Forms.Form
$dummyForm.WindowState = 'Minimized'
$dummyForm.ShowInTaskbar = $false
$dummyForm.ShowDialog() | Out-Null
