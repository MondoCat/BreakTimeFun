# Break Time Fun (BTF) for WSL on Windows!
Stop saying "WTF!?" when you and/or your partner hyperfocus for too long on an app and forget to do chores, make supper, eat, water the cats, feed the plants, or even neglect to pee... and start saying "BTF! <3" 


BTF is a completely customizable WSL app for enforcing breaks for a particular app. 


By default, there is a forced break after each interval of ***1 hour played of the Steam game, [Factorio](https://store.steampowered.com/app/427520/Factorio/) .*** (If you've played Factorio, you know why, heh.) 


This app also features a "Snooze" button so you can finish up what you're working on before taking your break. There is also the "No, I'm not taking my break" option, but that only gets you so far...

# WTF is WSL? What's this ".sh" bullshit? Where is my .exe!?
It's okay if you dont understand WSL or Ubuntu/Linux. I didn't either this time last year, and there's not really any good guides on how to get started with it as a newbie without being a Linux pr0, so I will include a "I know 0 Linux to novice" guide here for you at the bottom section called "Installing WSL, Downloading YAD, and Running btf.sh for Newbies".

* WSL means Windows Subsystem for Linux. It basically means we're running "Command Line Linux" as a program on Windows! Pretty cool and no dual boot needed.
* Command Line can look really scary if you've never used it, but not to worry! It's actually pretty easy if you know the commands. I'll teach you, don't worry!


# Installing WSL, Downloading YAD, and Running btf.sh for Pr0s (Newbie instructions are down below configuration)

* Install WSL in powershell with `wsl --install` and follow the prompts
* Update APT with `sudo apt update && sudo apt upgrade -y`
* Download and configure btf.sh to fit your needs (See below for configuration info)
* Put btf.sh in "C:/Mondo" or wherever you like
* Type `cd /mnt/c/mondo` (or wherever you saved it to)
* Set permissions with `chmod +x btf.sh`
* Run it with `./btf.sh`

  
# Ye Olde Configuration File
You can edit this configuration by opening the btf.sh in notepad on your windows computer! If you do though, you will have to install an extra program and run an extra command in Ubuntu after you save to "convert" the file to something Linux can read properly. (Blame Dos VS Linux end of line differences) 
* Step 1: Type `sudo apt install dos2unix` (enter) in Ubuntu (Linux) to install the converter.
* Step 2: Make changes to your config file in notepad. Save it in windows.
* Step 3: Naviagate to the file in Ubuntu (Instructions below how to naviate on Linux) and type `dos2unix btf.sh`
* Step 3: Run it with `./btf.sh`
    * Every time you change something in the config you have to save the .sh in notepad and re-run  `dos2unix btf.sh` before running `./btf.sh`


```
APP_NAME="factorio.exe"      # Use the Windows process name of the app (default: factorio.exe)
TIME_LIMIT_MINUTES=60        # Wait this long for the FIRST pop-up (default: 60 mins)
POPUP_INTERVAL_MINUTES=1     # Default interval for recurring pop-ups (default: 1 minute)
SNOOZE_SECONDS=30            # Snooze duration in seconds (default: 30 seconds)
CHECK_INTERVAL_SECONDS=30    # How often the script checks if the app is running (default: 30 seconds)
YAD_TIMEOUT=10               # How many seconds the pop-up stays on screen before timing out (default: 10 seconds)
START_HOUR=17                # Start monitoring at 5 PM (default: 17 which is 5pm)
STOP_HOUR=23                 # Stop monitoring at 11 PM (default: 23 which is 11pm)
```

# Installing WSL, Downloading YAD, and Running btf.sh for Newbies
Let's assume you don't know what linux is. Never heard of WSL, and maybe you've seen the command prompt or PowerShell on Windows but haven't really touched it. Can you run this app? Yes! Let me hold your hand as we walk through the valley of death. You will fear no terminal, for you are with me! You'll be saying, "Mondo! Your keyboard and your mouse, they comfort me, and now, I vaguely understand how to use a command prompt in WSL/Linux! At least good enough to run btf.sh!"

Just an FYI, using WSL/Linux/Ubunto pretty interchanably in this guide.

* Step 1: Open the Start Menu
* Step 2: Type "PowerShell" but do NOT hit enter
* Step 3: Right click "PowerShell" and hit "Run as Administrator"
* Step 4: Type `wsl --install` and hit enter (You can copy and paste this with Ctrl+C from Github and Ctrl+V in PowerShell but NOT in Ubuntu)
* Step 5: Restart your PC (Yes, you have to!)
* Step 6: Open the Start Menu
* Step 7: Type "Ubuntu"
* Step 8: You will be prompted to enter a username (Remember it!)
* Step 9: You will be prompted to enter a password (When you type, the letters will NOT show up on screen as letters OR asterisks. Type it deliberately and slowly!) (Remember your password!)
* Step 10: Re-enter your password to confirm it
* Step 11: You are now at Ubuntu command line!
* Step 12: Update your "Linux App Store" by typing `sudo apt update && sudo apt upgrade -y` and hit enter (You can copy this with Ctrl+C in Github but NOT Ctrl+V in Ubuntu! You can paste it by making the Ubuntu window active and "right clicking the mouse" to paste.  Yes it's not convenient.)
    * <small>Technically you can change from right click to paste to "Ctrl+Shift+V" to paste, but you need to right click the Ubuntu title bar, hit Properties, and checkmark "Use Ctrl+Shift+C/V as Copy/Paste")</small>
    * Learnin' Trivia: "Sudo" means "HEY! DO THIS OR ELSE!", "APT" means "Advanced Package Tool" (Kinda like Linux's app store!), and "-y" means "Yes"... So we're kind of saying "HEY! OPEN APT APP STORE, UPDATE IT & UPGRADE IT! Yes, do it!"
* Step 13: Next, we're going to install a dependency called "YAD" (Yet Another Dialogue). A dependency is kind of like "An app that requires another app to run". It's dependent upon it! Type `sudo apt-get install yad`
    * Learnin' Trivia: Some of these should sound familiar! "HEY! OPEN THE APP STORE, GET YAD, AND INSTALL IT!" (See you're becoming a Linux pro!)
* Step 14: Download btf.sh from this Github
* Step 15: Place it somewhere easy to access. For example, you may consider saving it to C:/mondo/btf.sh
    * Learnin' Trivia: Linux doesnt REALLY have a GUI File Manager like Windows does, so we have to type our way to naviage to C:/mondo/btf.sh. 
    * More Learnin' Trivia: Linux doesn't start us off in C:\, but it starts us off in the "home" directory. It's not displayed as "home", but is displayed as a Tilde "`~`", and has your user status after "$". So it will say something like "MYUSERNAME@DESKTOP-MYDESKTOP:`~`$". This is kind of like "Before C:/" So imagine if your File Explorer said "Mondo@MondosPC:`~`$/C:/mondo/" instead of just "C:/mondo". Kind of hard to wrap your head around, but you'll get it!
    * EVEN MOAR Learnin' Trivia: The "$" at the end means you are a regular user. The command 'sudo -i' is how you would change the "$" to a "#" and give yourself a kind of "admin" status. We don't need that here, but just an FYI!
* Step 16: Switch back to Ubuntu. We're going to "Change Directories" and "Mount" the drive we saved btf.sh in. (Remember mounting .isos? it's kinda like that!)
* Step 17: Type `cd /mnt/c/mondo` and hit enter. (See it's kinda like saying "From Home, Change Directory, & Mount C:/mondo")
    * Learnin' Trivia: You can type the command for directory, `dir` (enter) or list, `ls` (enter) to see all of the files in this directory! You can check if you're in the right directory by doing this.
    * More Learnin' Trivia; you can type `cd ../` (enter) to go back one folder. (For example, from C:/mondo to C:/) or `cd` to go to your home folder.
* Step 18: Next we need to give btf.sh permission to run! Type `chmod +x btf.sh` and hit enter
* Step 19: Now it's time to run the script! Type `./btf.sh` and hit enter
    * With the default settings, after an hour of running Factorio, it will prompt you to take a break! You can hit "No" to make me sad, you can hit "Snooze" to get a 30 second snooze, and you can hit "I'm Stepping Away" to get up, stretch, take a break and restart the timer!

# Disclaimer
I used Gemini to help write & troubleshoot this app. Yes, I am a disgrace to my family for not learning all of this by heart. No, I don't care. &hearts;
