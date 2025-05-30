# --- Utility Functions ---
function Write-MessageBox {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]				$Message,
        [string]									$Title    = 'Notice',
        [System.Windows.Forms.MessageBoxButtons]	$Buttons  = 'OK',
        [System.Windows.Forms.MessageBoxIcon]		$Icon     = 'Information'
    )
    return [System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon)
}



# --- Lossless Scaling Management ---
function Start-LosslessScaling {
	$LosslessExe = "D:\Modding\Lossless Scaling\LosslessScaling.exe"
	$LosslessConfigPath = "C:\Users\jonas\AppData\Local\Lossless Scaling\Settings.xml"

    if (Get-Process -Name 'LosslessScaling' -ErrorAction SilentlyContinue) {return}

    if (-Not (Test-Path $LosslessConfigPath)) {
        Write-Warning "Lossless Scaling config not found: $LosslessConfigPath"
        return
    }

    [xml]$cfg = Get-Content $LosslessConfigPath
	$cfg.Settings.WindowMaximized = "false"
	$cfg.Save($LosslessConfigPath)

    $global:LosslessProcess = Start-Process -FilePath $LosslessExe -WindowStyle Minimized -PassThru
}
function Stop-LosslessScaling {
    if ($global:LosslessProcess) {
		try {$global:LosslessProcess.CloseMainWindow() | Out-Null}
        catch {Stop-Process -Name 'LosslessScaling' -ErrorAction SilentlyContinue}
    }
}

# --- ProtonVPN Management ---
function Disconnect-ProtonVPN {
    if (Get-Process -Name 'ProtonVPN.WireGuardService' -ErrorAction SilentlyContinue) {
        Start-Process "C:\Program Files\Proton\VPN\ProtonVPN.Launcher.exe"
        Start-Sleep -Seconds 1
        python "C:\Users\jonas\OneDrive\Scripts\playnite\protonVPN disconnect.py" 0.4
    }
}

# --- RivaTuner Management ---
function Start-RivaTuner {
	if (Get-Process -Name 'RTSS' -ErrorAction SilentlyContinue) {return}
	$global:RTSSProcess = $true
	schtasks /run /tn 'RivaTuner'
}
function Stop-RivaTuner {
    if ($global:RTSSProcess) {
        try{(Get-WmiObject -Class Win32_Process -Filter "Name = 'RTSS.exe'").Terminate()} catch {}
    }
}




# --- Controller Connection ---
function Connect-Controller {
    [CmdletBinding()]
    param(
		[Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
        [ValidateSet('Wii','PS4','PS3')] [string[]]	$Type,
        [switch]									$Da,
        [switch]									$AsAdmin
    )

    foreach ($t in $Type) {
        if ($Da) { 
            $Response = 'Yes'
        }
        else {
            $Response = Write-MessageBox "Connect a $t controller?" -Title "Connect $t?" -Icon 'Question' -Buttons 'YesNoCancel'
        }
        switch ($Response) {
            'No'     { continue }
            'Cancel' { return }
        }

        switch ($t) {
			'Wii' { Connect-Wii -Da:$Da }
			'PS4' { Connect-PS4 -AsAdmin:$AsAdmin -Da:$Da }
			'PS3' { Connect-PS3 -Da:$Da }
        }
    }
}

function Connect-PS4 {
    param([switch]$AsAdmin)

    $global:DS4AlreadyRunning = Get-Process -Name 'DS4Windows' -ErrorAction SilentlyContinue

    if ($DS4AlreadyRunning -and $AsAdmin) {
        Stop-Process -Id $DS4AlreadyRunning.Id -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
    }

    if ($AsAdmin) {
        schtasks /run /tn 'DS4Windows administrator'
    }
    elseif (-not $DS4AlreadyRunning) {
        Start-Process 'D:\Program Files\DS4Windows_3.2.9_x64\DS4Windows\DS4Windows.exe' -WindowStyle Minimized -PassThru
    }
}
#will add the rest later



# --- Cleanup ---
function Close-Applications {
    Stop-LosslessScaling
    Stop-RivaTuner

    if (!$DS4AlreadyRunning) {
		schtasks /run /tn "DS4Windows Shutdown"
	}
}





# --- Legacy Compatibility ---
function choose_controller {
    param(
        $controller = '',
        [switch]$cancelbutton,
        [switch]$admin,
        [switch]$alert,
        [switch]$da
    )

    Connect-Controller -Type $controller -AsAdmin:$admin -Da:$da
}
