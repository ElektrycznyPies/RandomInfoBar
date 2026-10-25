# Random Info Bar # 1.3 #

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	function Set-Hover {
		param (
			[System.Windows.Forms.Button]$ButtonObject,
			[switch] $MouseEnter
		)
		if ($MouseEnter) {
			$bkColor = '#FF0000'
			$fgColor = '#000000'
		}
		else {
			$bkColor = '#000000'
			$fgColor = '#FF0000'
		}
		$ButtonObject.BackColor = $bkColor
		$ButtonObject.ForeColor = $fgColor
	}

	$form = New-Object System.Windows.Forms.Form
	$moveBtn = New-Object System.Windows.Forms.Button
	$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
	
	$s = @{
		netText = ""
		netSymbol = ""
		btnSymbol = "|||" # find line if ($s.windowX -gt -($s.formMaxX/2))... to change button symbols
		windowX = 0
		windowY = 0
		formMaxX = 600
		formMaxY = 24  # Less than 24 offsets move button click area to the left
		btnWidth = 25
		offsetY = 1 
	}
	
	$interval = 45000 # 60000 = 1 minute

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

	# Move button properties
	$moveBtn.Location = New-Object System.Drawing.Point(($s.formMaxX - $s.btnWidth), 0)
	$moveBtn.Size = New-Object System.Drawing.Size($s.btnWidth,$s.formMaxY)
	$moveBtn.FlatStyle = 'Flat'
	$moveBtn.FlatAppearance.BorderSize = 0
	$moveBtn.FlatAppearance.MouseDownBackColor = $moveBtn.BackColor
	$moveBtn.FlatAppearance.MouseOverBackColor = $moveBtn.BackColor
	$moveBtn.BackColor = '#000000'
	$moveBtn.ForeColor = '#FF0000'
	$moveBtn.TabStop = $false
	$moveBtn.Text = "|||"
	$moveBtn.Add_MouseEnter({ Set-Hover -ButtonObject $this -MouseEnter })
	$moveBtn.Add_MouseLeave({ Set-Hover -ButtonObject $this })
	$moveBtn.Add_MouseDown({
		if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left)
		{
			$script:dragging = $true
			$script:startMouseX = [System.Windows.Forms.Cursor]::Position.X
			$script:startFormX  = $form.Left
		}
	})
	$moveBtn.Add_MouseMove({
		if ($script:dragging)
		{
			$currentX = [System.Windows.Forms.Cursor]::Position.X
			$deltaX = $currentX - $script:startMouseX
			$s.windowX = $script:startFormX + $deltaX
			if ($s.windowX -lt -($s.formMaxX - $s.btnWidth)) { $s.windowX = -($s.formMaxX - $s.btnWidth) }
			if ($s.windowX -gt -($s.formMaxX/2)) { $moveBtn.Text = "|||" } else { $moveBtn.Text = "[ ]" }
			$form.Left = $s.windowX
		}
	})
	$moveBtn.Add_MouseUp({
		$script:dragging = $false
		$form.ActiveControl = $null
	})


	# Properties of text in the bar
	$label = New-Object System.Windows.Forms.Label
	$label.Size = New-Object System.Drawing.Size($s.formMaxX, $s.formMaxY)
	$label.Margin = New-Object System.Windows.Forms.Padding(0)
	$label.Padding = New-Object System.Windows.Forms.Padding(0)
	$label.TextAlign = "MiddleCenter"
	$label.ForeColor = "White"
	$label.Font = New-Object System.Drawing.Font("Helvetica", 15)
	
	
	$form.Controls.Add($label)
	$form.Controls.Add($moveBtn)
	$moveBtn.BringToFront()

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

		if ($s.windowX -gt -([math]::Round($s.formMaxX / 3))) {
		$s.windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $s.formMaxX)
		$s.windowY = $bounds.Height - $s.formMaxY - $s.offsetY
		$form.Location = New-Object System.Drawing.Point($s.windowX, $s.windowY)
		}
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
