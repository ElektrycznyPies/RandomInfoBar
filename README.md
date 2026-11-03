**Random Info Bar** -- a small information bar for Windows, designed with **OLED monitors** in mind. It lets you hide the Windows taskbar while keeping the clock, date and network connection status visible.

The bar has a black, partially transparent background and moves to a random position along the bottom or left edge of the screen every 45 seconds (customizable). This reduces prolonged exposure of the same pixels to bright text — useful during long sessions on an OLED display.

- Shows time, day of the week and date; also: physical network connection status: Ethernet, Wi-Fi, cellular or disconnected.
- Always-on-top.
- Left < / Bottom V Button to reorient the bar. 
- Move Button ||| to move the bar away in case it obscures something important.
- Move far left (when at the bottom) / far up (when on the left) to pause randomization. Move back to resume. 'O' sign indicates pause.
- Can run automatically at logon through Windows Task Scheduler.

**Task Scheduler** setup:
_Create task_ that will run powershell.exe with arguments -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Scripts\RandomInfoBar.ps1"

(Provide the correct file path, of course.)

You will easily find more info on how to use Task Scheduler [online](https://www.youtube.com/watch?v=DVrWfuKcDyM). 

_Random Info Bar_ was coded by me in PowerShell. It is free for private use until it changes. Any licensing changes will be posted here.

Dariusz Zen Żukowski (c) 2026
