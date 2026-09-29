# Random Info Bar #
# --------------- #
#
# OLED friendly script that displays basic information in a dark, random-positioned bar.
# Hide your taskbar and still see the time and date.
# Add this ps1 to the Windows Task Scheduler at logon to always see the bar.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

$formMaxX = 400
$formMaxY = 25
$interval = 60000

# Właściwości okna
$form.Text = "Watch, Date, Day"
$form.ClientSize=New-Object System.Drawing.Size($formMaxX,$formMaxY)
$form.StartPosition = "Manual"
$form.FormBorderStyle = "None"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::Black
$form.Opacity = 0.8
$form.TopMost = $true
$form.ShowInTaskbar = $false

	# Wymuszenie stylu ToolWindow bez przywracania ramek: stworzenie ukrytego okna nadrzędnego
	$owner = New-Object System.Windows.Forms.Form
	$owner.FormBorderStyle = "None"
	$owner.Size = New-Object System.Drawing.Size(0, 0)
	$owner.ShowInTaskbar = $false
	# Przypisanie właściciela
	$form.Owner = $owner

# Właściwości tekstu w oknie
$label = New-Object System.Windows.Forms.Label
$label.Size = "$formMaxX, $formMaxY"
$label.TextAlign = "MiddleCenter"
$label.ForeColor = "White"
$label.Font = New-Object System.Drawing.Font("Aptos", 16)
$form.Controls.Add($label)
	
	# Pierwsze wywołanie okna z napisami, inaczej poszłoby na 0,0
	$windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $formMaxX)
	$windowY = $bounds.Height - $formMaxY
	$label.Text = Get-Date -Format "[ HH:mm:ss ]  |  dddd, d MMMM yyyy"
	$form.Location = New-Object System.Drawing.Point($windowX, $windowY)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $interval

$timer.Add_Tick({

$windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $formMaxX)
$windowY = $bounds.Height - $formMaxY
$form.Location = New-Object System.Drawing.Point($windowX, $windowY)

})

$timerSeconds = New-Object System.Windows.Forms.Timer
$timerSeconds.Interval = 100
$timerSeconds.Add_Tick{(

$label.Text = Get-Date -Format "[ HH:mm:ss ]  |  dddd, d MMMM yyyy"

)}


$timer.Start()
$timerSeconds.Start()
$form.ShowDialog()
$timer.Stop()
$timerSeconds.Stop()
$form.Dispose()
$form = $null
