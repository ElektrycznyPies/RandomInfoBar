# Random Info Bar # 1.1 #

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
	
	$s = @{
		netText = ""
		netSymbol = ""
		windowX = 0
		windowY = 0
		formMaxX = 600
		formMaxY = 22
		offsetY = 0
	}
	
	$interval = 60000

	# Form properties
	$form.Text = "Random Info Bar"
	$form.StartPosition = "Manual"
	$form.Size = New-Object System.Drawing.Size($s.formMaxX, $s.formMaxY)
	$form.MaximumSize = New-Object System.Drawing.Size($s.formMaxX, $s.formMaxY)
	$form.MinimumSize = New-Object System.Drawing.Size($s.formMaxX, $s.formMaxY)
	$form.Margin = New-Object System.Windows.Forms.Padding(0)
	$form.FormBorderStyle = "None"
	$form.MaximizeBox = $false
	$form.BackColor = [System.Drawing.Color]::Black
	$form.Opacity = 0.8
	$form.TopMost = $true
	$form.ShowInTaskbar = $false
	#$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None
		
	# Properties of text in the bar
	$label = New-Object System.Windows.Forms.Label
	$label.Size = New-Object System.Drawing.Size($s.formMaxX, $s.formMaxY)
	$label.Margin = New-Object System.Windows.Forms.Padding(0)
	$label.Padding = New-Object System.Windows.Forms.Padding(0)
	$label.Dock = [System.Windows.Forms.DockStyle]::Fill
	$label.TextAlign = "MiddleCenter"
	$label.ForeColor = "White"
	$label.Font = New-Object System.Drawing.Font("Helvetica", 15)
	#$label.Dock = [System.Windows.Forms.DockStyle]::Fill
	
	$form.Controls.Add($label)
	
		# First call of window with labels, otherwise pos. would be 0,0
		$s.windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $s.formMaxX)
		$s.windowY = $bounds.Height - $s.formMaxY - $s.offsetY
		$label.Text = Get-Date -Format "[ HH:mm:ss ]  |  dddd, d MMMM yyyy"
		$s.netText = "net check"
		$form.Location = New-Object System.Drawing.Point($s.windowX, $s.windowY)

	# Timer to update network
	$timerNet = New-Object System.Windows.Forms.Timer
	$timerNet.Interval = 1500
	$timerNet.Add_Tick({
	
	# Network state
	$activeAdapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }

		if (-not $activeAdapters) {
			$s.netText = "NO NET" 
			$s.netSymbol = "*"
		} else {
			foreach ($adapter in $activeAdapters) {
				$connectionType = switch ([int]$adapter.InterfaceType) {
					6       { "ETH" }
					71      { "WI-FI" }
					243     { "GSM" }
					244     { "GSM" }
					Default { "OTHER: ($($adapter.InterfaceType))" }
				}

			# [$($adapter.Name)] gives adapter name :)
			$s.netText = "$connectionType"
			$s.netSymbol = "^"
			}
		}
	})


	# Timer to update bar position
	$timer = New-Object System.Windows.Forms.Timer
	$timer.Interval = $interval
	$timer.Add_Tick({

		$s.windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $s.formMaxX)
		$s.windowY = $bounds.Height - $s.formMaxY - $s.offsetY
		$form.Location = New-Object System.Drawing.Point($s.windowX, $s.windowY)

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
