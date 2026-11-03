# Random Info Bar # 1.4 #

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
$dirBtn = New-Object System.Windows.Forms.Button
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

$s = @{
	netText = ""
	netSymbol = ""
	dirSymbol = "<"
	windowX = 0
	windowY = 0
	formMaxX = 600
	formMaxY = 24
	btnWidth = 25
	offsetY = 1
	direction = "D" # D = down, L = left
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

# Move button properties
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
		$script:startMouseY = [System.Windows.Forms.Cursor]::Position.Y
		$script:startFormY  = $form.Top
	}
})
$moveBtn.Add_MouseMove({
	if ($script:dragging)
	{
		if ($s.direction -eq "D")
		{
			$currentX = [System.Windows.Forms.Cursor]::Position.X
			$deltaX = $currentX - $script:startMouseX
			$s.windowX = $script:startFormX + $deltaX
			if ($s.windowX -lt -($s.formMaxX - $s.btnWidth)) { $s.windowX = -($s.formMaxX - $s.btnWidth) }
			if ($s.windowX -gt -($s.formMaxX/2)) { $moveBtn.Text = "|||" } else { $moveBtn.Text = "O" }
			$form.Left = $s.windowX
		}
		else
		{
			$currentY = [System.Windows.Forms.Cursor]::Position.Y
			$deltaY = $currentY - $script:startMouseY
			$s.windowY = $script:startFormY + $deltaY
			if ($s.windowY -lt -($s.formMaxY - $s.btnWidth)) { $s.windowY = -($s.formMaxY - $s.btnWidth) }
			if ($s.windowY -gt -($s.formMaxY/2)) { $moveBtn.Text = "|||" } else { $moveBtn.Text = "O" }
			$form.Top = $s.windowY
		}
	}
})
$moveBtn.Add_MouseUp({
	$script:dragging = $false
	$form.ActiveControl = $null
})

# Direction button properties
$dirBtn.FlatStyle = 'Flat'
$dirBtn.FlatAppearance.BorderSize = 0
$dirBtn.FlatAppearance.MouseDownBackColor = $dirBtn.BackColor
$dirBtn.FlatAppearance.MouseOverBackColor = $dirBtn.BackColor
$dirBtn.BackColor = '#000000'
$dirBtn.ForeColor = '#FF0000'
$dirBtn.TabStop = $false
$dirBtn.Text = $s.dirSymbol
$dirBtn.Add_MouseEnter({ Set-Hover -ButtonObject $this -MouseEnter })
$dirBtn.Add_MouseLeave({ Set-Hover -ButtonObject $this })
$dirBtn.Add_Click({
	if ($s.direction -eq "D") { 
		$s.direction = "L" 
		$s.formMaxX = 60
		$s.formMaxY = 300
		$s.dirSymbol = "V"
	} else { 
		$s.direction = "D" 
		$s.formMaxX = 600 
		$s.formMaxY = 24
		$s.dirSymbol = "<"
	}

	$form.Size = $form.MaximumSize = $form.MinimumSize = New-Object System.Drawing.Size($s.formMaxX, $s.formMaxY)
	$dirBtn.Text = $s.dirSymbol
	$moveBtn.Text = "|||"

	if ($s.direction -eq "L") {
		$label.Size = New-Object System.Drawing.Size($s.formMaxX, ($s.formMaxY - $s.btnWidth))
		$dirBtn.Location = New-Object System.Drawing.Point(0, ($s.formMaxY - $s.btnWidth))
		$dirBtn.Size = New-Object System.Drawing.Size($s.btnWidth, $s.btnWidth)
		$moveBtn.Location = New-Object System.Drawing.Point($s.btnWidth, ($s.formMaxY - $s.btnWidth))
		$moveBtn.Size = New-Object System.Drawing.Size($s.btnWidth, $s.btnWidth)
		$s.windowX = 0
		$s.windowY = Get-Random -Minimum 0 -Maximum ($bounds.Height - $s.formMaxY)
	} else {
		$label.Size = New-Object System.Drawing.Size($s.formMaxX, $s.formMaxY)
		$dirBtn.Location = New-Object System.Drawing.Point(($s.formMaxX - ($s.btnWidth * 2)), 0)
		$dirBtn.Size = New-Object System.Drawing.Size($s.btnWidth, $s.formMaxY)
		$moveBtn.Location = New-Object System.Drawing.Point(($s.formMaxX - $s.btnWidth), 0)
		$moveBtn.Size = New-Object System.Drawing.Size($s.btnWidth, $s.formMaxY)
		$s.windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $s.formMaxX)
		$s.windowY = $bounds.Height - $s.formMaxY - $s.offsetY
	}
	$form.Location = New-Object System.Drawing.Point($s.windowX, $s.windowY)
})

# Properties of text in பீ the bar
$label = New-Object System.Windows.Forms.Label
$label.Size = New-Object System.Drawing.Size($s.formMaxX, $s.formMaxY)
$label.Margin = New-Object System.Windows.Forms.Padding(0)
$label.Padding = New-Object System.Windows.Forms.Padding(0)
$label.TextAlign = "MiddleCenter"
$label.ForeColor = "White"
$label.Font = New-Object System.Drawing.Font("Helvetica", 15)

# Initial button layout (Default: Down)
$dirBtn.Location = New-Object System.Drawing.Point(($s.formMaxX - ($s.btnWidth * 2)), 0)
$dirBtn.Size = New-Object System.Drawing.Size($s.btnWidth, $s.formMaxY)
$moveBtn.Location = New-Object System.Drawing.Point(($s.formMaxX - $s.btnWidth), 0)
$moveBtn.Size = New-Object System.Drawing.Size($s.btnWidth, $s.formMaxY)

$form.Controls.Add($label)
$form.Controls.Add($moveBtn)
$form.Controls.Add($dirBtn)
$moveBtn.BringToFront()
$dirBtn.BringToFront()

# Initial position
$s.windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $s.formMaxX)
$s.windowY = $bounds.Height - $s.formMaxY - $s.offsetY
$form.Location = New-Object System.Drawing.Point($s.windowX, $s.windowY)

# Timer to update network
$timerNet = New-Object System.Windows.Forms.Timer
$timerNet.Interval = 1500
$timerNet.Add_Tick({
	$activeAdapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
	if (-not $activeAdapters) {
    $s.netText     = "NO NET"   # Poziomo
    $s.netSymbol   = "*"
    $s.netVertical = "*n"       # Pionowo
		} else {
			foreach ($adapter in $activeAdapters) {
				switch ([int]$adapter.InterfaceType) {
					6       { 
						$s.netText     = "ETH"   # Wpisz co chcesz dla poziomego Ethernetu
						$s.netVertical = "^E"    # Wpisz co chcesz dla pionowego Ethernetu
					}
					71      { 
						$s.netText     = "WIFI" # Wpisz co chcesz dla poziomego Wi-Fi
						$s.netVertical = "^W"    # Wpisz co chcesz dla pionowego Wi-Fi
					}
					Default { 
						$s.netText     = "OTH" 
						$s.netVertical = "^?"
					}
				}
				$s.netSymbol = "^"
			}
		}
})

# Timer to update bar position
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $interval
$timer.Add_Tick({
	if ($s.direction -eq "D") {
		if ($s.windowX -gt -([math]::Round($s.formMaxX / 3))) {
			$s.windowX = Get-Random -Minimum 0 -Maximum ($bounds.Width - $s.formMaxX)
			$s.windowY = $bounds.Height - $s.formMaxY - $s.offsetY
			$form.Location = New-Object System.Drawing.Point($s.windowX, $s.windowY)
		}
	} else {
		if ($s.windowY -gt -([math]::Round($s.formMaxY / 3))) {
			$s.windowX = 0
			$s.windowY = Get-Random -Minimum 0 -Maximum ($bounds.Height - $s.formMaxY)
			$form.Location = New-Object System.Drawing.Point($s.windowX, $s.windowY)
		}
	}
})

# Timer to update time & text
$timerSeconds = New-Object System.Windows.Forms.Timer
$timerSeconds.Interval = 100
$timerSeconds.Add_Tick({
	if ($s.direction -eq "D") {
		$dateText = Get-Date -Format "[ HH:mm:ss ]      dddd, d MMMM yyyy" 
		$label.Text = "$dateText    $($s.netSymbol) $($s.netText) $($s.netSymbol)"
	} else {
		$timeText = Get-Date -Format "HH`nmm`nss"
		$dateText = Get-Date -Format "ddd`nd.MM"
		$label.Text = "$timeText`n`n$dateText`n`n$($s.netVertical)"
	}
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
