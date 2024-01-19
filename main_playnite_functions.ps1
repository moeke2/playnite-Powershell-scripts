function choose_controller{
	param(
		$controller = '',
		$cancel_button = 0,
		[switch]$admin,
		$connect_alert = 0
	)
	
	if ($cancel_button -eq 1){
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
	
	switch ($popup) {
		'Yes'    {
			switch ($controller){
				'wii'	{							
							Start-Process -FilePath "explorer.exe" "ms-settings:bluetooth"
							Start-Sleep -s 1
							Start-Process -FilePath "explorer.exe" "shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}"
							
							$popup = [System.Windows.Forms.MessageBox]::Show("Click OK if all your Wiimote's are connected.", "Connect your Wiimote's", "OKCancel", 32)
							if ($popup -eq 'Ok') {
								$script:wiimotehook = Start-Process "D:\Program Files\WiimoteHook\WiimoteHook.exe" -WindowStyle Minimized -PassThru
								$script:wiimotehook_popup = Start-Process powershell -ArgumentList "D:\Games\Playnite\_playnite_scripts\'Wiimote popup.ps1'" -NoNewWindow -PassThru}
						}
				'ps4'	{
							$code = '$script:ds4 = Start-Process "D:\Program Files\DS4Windows_3.2.9_x64\DS4Windows\DS4Windows.exe" -WindowStyle Minimized -PassThru'
							if ($admin){$code += ' -Verb RunAs'}
							Invoke-Expression $Code
							
							if ($connect_alert -eq 1) {[System.Windows.Forms.MessageBox]::Show("Make sure you have your controllers connected via bluetooth!", "Important!", "OK", 64)}
							
						}
				'ps3'	{}
				default {[System.Windows.Forms.MessageBox]::Show("something is wrong with your playnite input")}
				
			}
		}
		'No'     { return}
		'Cancel' { exit }
		default  { return }
	}
}

function clean_apps{
	try {$wiimotehook.CloseMainWindow()} catch {}
	try {Stop-Process -Id $wiimotehook_popup.Id} catch {}
	try {Stop-Process -Id $ds4.Id} catch {try{(Get-WmiObject -Class Win32_Process -Filter "ProcessId = $($ds4.Id)").Terminate()} catch {}}
}

#this command worked when i tested it: Start-Process powershell "D:\Games\Playnite\_playnite_scripts\'Wiimote popup.ps1'" -NoNewWindow 