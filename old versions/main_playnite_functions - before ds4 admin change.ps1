function no_popup{
	$global:nopopup = $true
}

function choose_controller{
	param(
		$controller = '',
		[switch]$cancelbutton,
		[switch]$admin,
		[switch]$alert, #connect alert 
		[switch]$da #don't ask
	)
	if ($da){ $script:popup = 'Yes'}
	else {
	if ($nopopup){
		if ($connect_alert -eq 1) {[System.Windows.Forms.MessageBox]::Show("Make sure you have your controllers connected via bluetooth!", "Important!", "OK", 64)}
		return
	} 
	
	if ($cancelbutton){
		$ButtonType = 'YesNoCancel'
		$MessageBody = "Do you want to connect a ${controller} controller?`n`nclick 'cancel' if you want to stop connecting controllers."
	}
	else{
		$ButtonType = 'YesNo'
		$MessageBody = "Do you want to connect a ${controller} controller?"
	}
	$MessageIcon = 'Question'
	$MessageTitle = "Connect ${controller}?"
	$popup = [System.Windows.Forms.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)
	
	}
	
	switch ($popup) {
		'Yes'    {
			switch ($controller){
				'wii'	{	
							if (Get-Process -Name "WiimoteHook" -ErrorAction SilentlyContinue) {Stop-Process -Name "WiimoteHook"}
							Start-Process -FilePath "explorer.exe" "ms-settings:bluetooth"
							Start-Sleep -s 1
							Start-Process -FilePath "explorer.exe" "shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}"
							
							$popup = [System.Windows.Forms.MessageBox]::Show("Click OK if all your Wiimote's are connected.", "Connect your Wiimote's", "OKCancel", 32)
							if ($popup -eq 'Ok') {
								$script:wiimotehook = Start-Process "D:\Program Files\WiimoteHook\WiimoteHook.exe" -WindowStyle Minimized -PassThru
								$script:wiimotehook_popup = Start-Process powershell -ArgumentList "D:\Games\Playnite\_playnite_scripts\'Wiimote popup.ps1'" -PassThru -WindowStyle Minimized} #-NoNewWindow 
						}
				'ps4'	{
							if (Get-Process -Name "DS4Windows" -ErrorAction SilentlyContinue) {
								if (!$admin){return}
								(Get-WmiObject -Class Win32_Process -Filter "Name = 'DS4Windows.exe'").Terminate()
							}
							$code = '$script:ds4 = Start-Process "D:\Program Files\DS4Windows_3.2.9_x64\DS4Windows\DS4Windows.exe" -WindowStyle Minimized -PassThru'
							if ($admin){$code += ' -Verb RunAs'}
							Invoke-Expression $Code
							
							#if ($alert) {[System.Windows.Forms.MessageBox]::Show("Make sure you have your controllers connected via bluetooth!", "Important!", "OK", 64)}
							
						}
				'ps3'	{	
							if (Get-Process -Name "DSHMC" -ErrorAction SilentlyContinue) {Stop-Process -Name "DSHMC"}
							$filepath = "C:\Windows\System32\DriverStore\FileRepository\bthps3.inf_amd64_213789b016987d0d\BthPS3.inf"
							if (-not (Test-Path $filepath)) {[System.Windows.Forms.MessageBox]::Show("Bluetooth is disabled for your ps3 controllers during this game session. `nDownload bthPS3 and restart your pc!", "BthPS3 not installed")}
							$filepath = "C:\Windows\System32\DriverStore\FileRepository\dshidmini.inf_amd64_b2b3954f90e159b0\dshidmini.inf"
							if (-not (Test-Path $filepath)) {
								Start-Process "D:\Program Files\dshidmini_v2.2.282.0\x64\dshidmini"
								$popup = [System.Windows.Forms.MessageBox]::Show("Click OK if you have installed dshidmini.inf", "Install dshidmini driver", "OKCancel", 32)
								if ($popup -eq 'Ok') {$script:ds3 = Start-Process "D:\Program Files\dshidmini_v2.2.282.0\DSHMC.exe" -WindowStyle Minimized -PassThru } }
							else {$script:ds3 = Start-Process "D:\Program Files\dshidmini_v2.2.282.0\DSHMC.exe" -WindowStyle Minimized -PassThru }
							Start-Sleep -s 1
						}
				default {[System.Windows.Forms.MessageBox]::Show("something is wrong with your playnite input")}
				
			}
		}
		'No'     { return}
		'Cancel' { exit }
		default  { return }
	}
}

function clean_apps{
	if ($wiimotehook) {
		try {$wiimotehook.CloseMainWindow()} catch {try{Stop-Process -Name "WiimoteHook"} catch{}}
		try {Stop-Process -Id $wiimotehook_popup.Id} catch {} }
	if ($ds4) {
		try {(Get-WmiObject -Class Win32_Process -Filter "ProcessId = $($ds4.Id)").Terminate()} catch {try{Stop-Process -Name "DS4Windows"} catch {}} }
	if ($ds3) {
		try{Stop-Process -Id $ds3.Id}catch{} 
		$script:ds3= Start-Process "D:\Program Files\dshidmini_v2.2.282.0\DSHMC.exe" -PassThru }
}

