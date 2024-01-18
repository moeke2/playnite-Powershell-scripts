# RUN BEFORE STARTING A GAME
function ChooseController{
	param(
		$Controller = '',
		$MultipleOptions = 0,
		$Admin = '',
		$ConnectAlert = 0
	)
	
	if ($MultipleOptions -eq 1){
		$ButtonType = 'YesNoCancel'
		$MessageBody = "Do you want to connect a ${Controller} controller?`n`nclick 'cancel' if you want to stop connecting controllers."
	}
	
	else{
		$ButtonType = 'YesNo'
		$MessageBody = "Do you want to connect a ${Controller} controller?"
	}
	
	$MessageIcon = 'Question'
	$MessageTitle = "Connect ${Controller}?"

	$Result = [System.Windows.Forms.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)
	
	switch ($Result) {
		'Yes'    {
			switch ($Controller){
				'wii'	{							
							$Code = 'Start-Process -FilePath "ms-settings:bluetooth"'+"`n"
							$Code += 'Start-Sleep -s 1'+"`n"
							$Code += 'Start-Process -FilePath "shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}"'+"`n"
							Invoke-Expression $Code
							
							$Result = [System.Windows.Forms.MessageBox]::Show("Click OK if all your Wiimote's are connected.", "Connect your Wiimote's", "OKCancel", 32)
							if ($Result -eq 'Ok') {Start-Process "D:\Program Files\WiimoteHook\WiimoteHook.exe" -WindowStyle Minimized}
						}
				'ps4'	{
							$Code = 'Start-Process "D:\Program Files\DS4Windows_3.2.9_x64\DS4Windows\DS4Windows.exe" -WindowStyle Minimized'
							if ($Admin -eq 'admin'){$Code += ' -Verb RunAs'}
							$Code += "`n"
							if ($ConnectAlert -eq 1) {$Code += '[System.Windows.Forms.MessageBox]::Show("Make sure you have your controllers connected via bluetooth!", "Important!", "OK", 64)'}
							Invoke-Expression $Code
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
#RUN AFTER A GAME IS STARTED

#RUN AFTER EXITING A GAME
function Close{
	param(
		$Controller = ''
	)
	switch ($Controller){
		'wii'	{									}
		'ps4'	{(Get-WmiObject -Class Win32_Process -Filter "name = 'DS4Windows.exe'").Terminate()}
	}
}