# Random Info Bar 1.0 #

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
	
	$s = @{
		netText = ""
		netSymbol = ""
	}
	
	$formMaxX = 600
	$formMaxY = 20
	$interval = 60000

	# Właściwości okna
	$form.Text = "Random Info Bar"
	$form.ClientSize=New-Object System.Drawing.Size($formMaxX,$formMaxY)
	$form.StartPosition = "Manual"
	$form.FormBorderStyle = "None"
	$form.MaximizeBox = $false
	$form.BackColor = [System.Drawing.Color]::Black
	$form.Opacity = 0.8
	$form.TopMost = $true
	$form.ShowInTaskbar = $false

		# ToolWindow style forced w/o frames: hidden tool window
		$owner = New-Object System.Windows.Forms.Form
		$owner.FormBorderStyle = "None"
		$owner.Size = New-Object System.Drawing.Size(0, 0)
		$owner.ShowInTaskbar = $false
		# Przypisanie właściciela
		$form.Owner = $owner

	# Properties of text in the bar
	$label = New-Object System.Windows.Forms.Label
	$label.Size = "$formMaxX, $formMaxY"
	$label.TextAlign = "MiddleCenter"
	$label.ForeColor = "White"
	$label.Font = New-Object System.Drawing.Font("Helvetica", 16)
	$form.Controls.Add($label)
	
		# First call of window with labels, otherwise pos. would be 0,0
		$windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $formMaxX)
		$windowY = $bounds.Height - $formMaxY
		$label.Text = Get-Date -Format "[ HH:mm:ss ]  |  dddd, d MMMM yyyy"
		$s.netText = "net check"
		$form.Location = New-Object System.Drawing.Point($windowX, $windowY)

	# Timer to update network
	$timerNet = New-Object System.Windows.Forms.Timer
	$timerNet.Interval = 1500
	$timerNet.Add_Tick({
	
	# Network state
	$activeAdapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }

		if (-not $activeAdapters) {
			$s.netText = "NO NET" 
			$s.netSymbol = "⇓"
		} else {
			foreach ($adapter in $activeAdapters) {
				$connectionType = switch ([int]$adapter.InterfaceType) {
					6       { "ETH" }
					71      { "WI-FI" }
					243     { "GSM" }
					244     { "GSM" }
					Default { "OTHER: ($($adapter.InterfaceType))" }
				}

			#Write-Host "Aktywne połączenie: $connectionType [$($adapter.Name)]" -ForegroundColor Green
			#$s.netText = "$connectionType [ $($adapter.Name) ]"
			$s.netText = "$connectionType"
			$s.netSymbol = "⇑"
			}
		}
	})


	# Timer to update bar position
	$timer = New-Object System.Windows.Forms.Timer
	$timer.Interval = $interval
	$timer.Add_Tick({

		$windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $formMaxX)
		$windowY = $bounds.Height - $formMaxY
		$form.Location = New-Object System.Drawing.Point($windowX, $windowY)

		})

	# Timer to update time
	$timerSeconds = New-Object System.Windows.Forms.Timer
	$timerSeconds.Interval = 100
	$timerSeconds.Add_Tick({
		
		$dateText = Get-Date -Format "[ HH:mm:ss ]     dddd, d MMMM yyyy" 
		$label.Text = "$dateText    $($s.netSymbol) $($s.netText) $($s.netSymbol)"
		
	})
	
$timer.Start()
$timerSeconds.Start()
$timerNet.Start()
$form.ShowDialog()
$timer.Stop()
$timerSeconds.Stop()
$timerNet.Stop()
$form.Dispose()
$form = $null
