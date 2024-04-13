Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
	
$popup_box 					= New-Object System.Windows.Forms.Form 
$popup_box.Text 			= "Wiimote reset"
$popup_box.Size				= New-Object System.Drawing.Size(225, 105)
$popup_box.StartPosition	= 'CenterScreen'
$popup_box.FormBorderStyle 	= 'FixedDialog'
$popup_box.ControlBox     	= $false
$popup_box.WindowState 		= 'Minimized'

$button						= New-Object System.Windows.Forms.Button
$button.Text     			= "Restart configuration"
$button.Size     			= New-Object System.Drawing.Size(190, 50)
$button.Location 			= New-Object System.Drawing.Point(10, 10)

$action = {
	$popup_box.Hide()	
	
	if (Get-Process -Name "WiimoteHook" -ErrorAction SilentlyContinue) {Stop-Process -Name "WiimoteHook"}
	Start-Process -FilePath "explorer.exe" "ms-settings:bluetooth"
	Start-Sleep -s 1
	Start-Process -FilePath "explorer.exe" "shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}"
	
	$popup = [System.Windows.Forms.MessageBox]::Show("Click OK if all your Wiimote's are connected.", "Connect your Wiimote's", "OKCancel", 32)
	if ($popup -eq 'Ok') {
	$script:wiimotehook = Start-Process "D:\Program Files\WiimoteHook\WiimoteHook.exe" -WindowStyle Minimized -PassThru}
	
	$popup_box.WindowState = 'Minimized'
	$popup_box.Show()
}

$button.Add_Click($action)

$popup_box.Controls.Add($button)

$result = $popup_box.ShowDialog()

