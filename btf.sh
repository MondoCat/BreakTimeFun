#!/bin/bash

# --- CONFIGURATION ---
APP_NAME="factorio.exe"      # Use the Windows process name of the app (default: factorio.exe)
TIME_LIMIT_MINUTES=60        # Wait this long for the FIRST pop-up (default: 60 mins)
POPUP_INTERVAL_MINUTES=1     # Default interval for recurring pop-ups (default: 1 minute)
SNOOZE_SECONDS=30            # Snooze duration in seconds (default: 30 seconds)
CHECK_INTERVAL_SECONDS=30    # How often the script checks if the app is running (default: 30 seconds)
YAD_TIMEOUT=10               # How many seconds the pop-up stays on screen before timing out (default: 10 seconds)
START_HOUR=17                # Start monitoring at 5 PM (default: 17 which is 5pm)
STOP_HOUR=23                 # Stop monitoring at 11 PM (default: 23 which is 11pm)
# ------------------------------------

TIME_LIMIT_SECONDS=$((TIME_LIMIT_MINUTES * 60))
POPUP_INTERVAL_SECONDS=$((POPUP_INTERVAL_MINUTES * 60))

first_seen_timestamp=0 # Timestamp for when the app was first detected
last_popup_timestamp=0 # Timestamp for when the last pop-up was shown

echo "Monitoring '$APP_NAME'. A recurring pop-up will appear after it runs for $TIME_LIMIT_MINUTES minute(s)."

while true; do
  current_hour=$(date +%H)

  if [ "$current_hour" -ge "$START_HOUR" ] && [ "$current_hour" -lt "$STOP_HOUR" ]; then
    pid=$(tasklist.exe | grep -i "$APP_NAME" | awk '{print $2}')

    if [ -n "$pid" ]; then
      if [ "$first_seen_timestamp" -eq 0 ]; then
        first_seen_timestamp=$(date +%s)
        echo "Detected '$APP_NAME' (PID: $pid). Starting timer."
      fi

      current_timestamp=$(date +%s)
      monitoring_duration=$((current_timestamp - first_seen_timestamp))
      
      if [ "$monitoring_duration" -gt "$TIME_LIMIT_SECONDS" ]; then
        if [ $((current_timestamp - last_popup_timestamp)) -ge "$POPUP_INTERVAL_SECONDS" ]; then
          
          pkill -9 -f "yad --title=Break Time Fun"
          sleep 0.1
          
          yad --title="Break Time Fun" \
              --text="\n\n<big>You have been running <b>$APP_NAME</b> for a while.</big>\n\nTime for a break? ♥ :)\n\n" \
              --button="No:0" \
              --button="Snooze 30s:1" \
              --button="I'm stepping away!:2" \
              --timeout="$YAD_TIMEOUT" \
              --width=400 --text-align=center 2>/dev/null
          
          choice=$?

          case $choice in
            0) # User clicked "No"
              echo "Displaying sad face for 1 second..."
              yad --text="\n\nThat is the wrong answer... :(" --title="Break Time Fun" --no-buttons --timeout=1 --center \
                  --width=400 --text-align=center 2>/dev/null
              last_popup_timestamp=0
              continue
              ;;
            1) # User clicked "Snooze 30s"
              echo "Snoozing for $SNOOZE_SECONDS seconds..."
              yad --text="\n\nGiving you a little more time. Hurry up!" --title="Break Time Fun" --no-buttons --timeout=1 --center \
                  --width=400 --text-align=center 2>/dev/null
              last_popup_timestamp=$((current_timestamp - POPUP_INTERVAL_SECONDS + SNOOZE_SECONDS))
              ;;
            2) # User clicked "I'm stepping away!"
              echo "Displaying 'Thank you'..."
              yad --text="\n\n♡❤︎♥︎ Thank You ♥︎❤︎♡" --title="Break Time Fun" --no-buttons --timeout=1 --center \
                  --width=400 --text-align=center 2>/dev/null
              
              loop_start_time=$(date +%s)
              while [ $(( $(date +%s) - loop_start_time )) -lt 180 ]; do
                pid_check=$(tasklist.exe | grep -i "$APP_NAME")
                if [ -z "$pid_check" ]; then
                  echo "$APP_NAME closed. Exiting 'Thank you' loop."
                  break
                fi
                pkill -9 -f "yad --title=Break Time Fun"
                yad --text="\n\n<big>♡❤︎♥︎ Thank You ♥︎❤︎♡</big>" --title="Break Time Fun" --no-buttons --timeout=2 --center \
                    --width=400 --text-align=center 2>/dev/null
              done
              
              echo "Timer reset. You've stepped away."
              first_seen_timestamp=$(date +%s)
              last_popup_timestamp=$(date +%s)
              ;;
            *) # Timed out or user closed the window
              echo "Pop-up timed out. Re-issuing in 1 second."
              last_popup_timestamp=0
              sleep 1
              continue
              ;;
          esac
        fi
      fi
    else
      # If the process is not running, reset our timers
      first_seen_timestamp=0
      last_popup_timestamp=0
    fi
  else
    # Reset outside monitoring hours
    first_seen_timestamp=0
    last_popup_timestamp=0
  fi

  sleep "$CHECK_INTERVAL_SECONDS"
done