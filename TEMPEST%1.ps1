#VERSION 0.0.0.1
#Name: TEMPEST%1.ps1
#DEV:Daniel Estrella



Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$WorkingPath = Get-Location
$NNAME 
$LogBoxReady = $False
$serial = (Get-WmiObject -Class Win32_BIOS).SerialNumber
if (-not $serial) {
    Write-Host "Serial number is null or empty. Using default 'UNKNOWN'."
    $serial = "UNKNOWN"
}

    function Watch-Time
    {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date) 
    }

$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$weekDay = (Get-Date).DayOfWeek
$logFilePath = "$WorkingPath\HISTORY\${serial}_SCRIPT_A_${date}_${weekDay}.txt"
Start-Transcript -Path $logFilePath -NoClobber
Write-Host "Logging started at $logFilePath"

function send-ToLog {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [Parameter()]
        [string]$Level = "INFO",
        [Parameter()]
        [bool]$ShowArt = $false  
    )
    
    $timestamp = Watch-Time
    if ($ShowArt) {
        $Message =
        "                                      " + [Environment]::NewLine +
        "           _____ ___ __ __ ___ ___  __ _____ " + [Environment]::NewLine + 
        "          |_   _| __|  V  | _,\ __/' _/_   _|" + [Environment]::NewLine +
        "            | | | _|| \_/ | v_/ _|`._`. | |  " + [Environment]::NewLine +
        "            |_| |___|_| |_|_| |___|___/ |_|  " + [Environment]::NewLine;
    }


    Write-Host "$timestamp [$Level] $Message"

    if ($Script:LogBoxReady) {
        try {
            $Script:TEMPEST_Form.Invoke([Action]{
                $Script:LogTextBox.AppendText("$timestamp [$Level] $Message`r`n")
            })
            Increment-ProgressBar 1
        } catch {
            Write-Host "Unable to append to LogTextBox: $_"
        }
    } else {
        #Write-Host "LogTextBox is not ready or does not exist."
    }
}



# #Color Guide
# $Primary1Color = [System.Drawing.Color]::FromArgb(0, 71, 171)  
# $Primary2Color = [System.Drawing.Color]::FromArgb(135, 206, 235)  
# $Secondary1Color = [System.Drawing.Color]::FromArgb(255, 69, 0) 
# $Secondary2Color = [System.Drawing.Color]::FromArgb(0, 255, 0)  
# $Secondary3Color = [System.Drawing.Color]::FromArgb(0, 128, 128)  
# $Neutral1Color = [System.Drawing.Color]::FromArgb(150, 150, 150)  
# $Neutral2Color = [System.Drawing.Color]::FromArgb(254, 254, 254)  
# $Neutral3Color = [System.Drawing.Color]::FromArgb(30, 30, 30)  

# Dark Mode Color Guide
$Primary1Color = [System.Drawing.Color]::FromArgb(100, 149, 237)  
$Primary2Color = [System.Drawing.Color]::FromArgb(173, 216, 230)  
$Secondary1Color = [System.Drawing.Color]::FromArgb(255, 140, 0)  
$Secondary2Color = [System.Drawing.Color]::FromArgb(0, 255, 100)  
$Secondary3Color = [System.Drawing.Color]::FromArgb(64, 224, 208)  
$Neutral1Color = [System.Drawing.Color]::FromArgb(180, 180, 180)  
$Neutral2Color = [System.Drawing.Color]::FromArgb(40, 40, 40)      
$Neutral3Color = [System.Drawing.Color]::FromArgb(255, 255, 255)      


function Show-DistrictForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Enter District'
    $form.Size = New-Object System.Drawing.Size(300,200)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = $Neutral2Color
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

    $iconBase64 = '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'
    $iconBytes = [Convert]::FromBase64String($iconBase64)
    $stream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
    $form.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Please enter District (5, 7, 9, 11, 69 ):"
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.ForeColor = $Primary1Color

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,40)
    $textBox.Size = New-Object System.Drawing.Size(260,20)
    $textBox.TabIndex = 0
    $textBox.BackColor = $Neutral2Color
    $textBox.ForeColor = $Primary1Color

    $button = New-Object System.Windows.Forms.Button
    $button.Text = 'OK'
    $button.Location = New-Object System.Drawing.Point(10,130)
    $button.TabIndex = 1
    $button.BackColor = $Secondary1Color
    $button.ForeColor = $Neutral2Color

    $button.Add_Click({
        $Script:DISTRICT = $textBox.Text
        if ($Script:DISTRICT -match "^(5|7|9|11|69)$") {
            $form.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Incorrect District. Try again.", "Error", 'OK', 'Error')
            $textBox.Clear()
        }
    })

    
    $form.AcceptButton = $button

    $form.Controls.Add($label)
    $form.Controls.Add($textBox)
    $form.Controls.Add($button)

    $form.Topmost = $true

    
    $form.Add_Shown({$textBox.Select()})
    
    $form.ShowDialog()
}



Show-DistrictForm
$GPSdata = $DISTRICT
$GPSpath= "$WorkingPath\CYPHER\GPS.txt"
$GPSdata | Out-File $GPSpath








function Show-CredentialForm {

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Admin Credential Input'
    $form.Size = New-Object System.Drawing.Size(300,200)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = $Neutral2Color
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $iconBase64 = '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'
    $iconBytes = [Convert]::FromBase64String($iconBase64)
    $stream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
    $form.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))
    $labelUser = New-Object System.Windows.Forms.Label
    $labelUser.Text = "Username:"
    $labelUser.Location = New-Object System.Drawing.Point(10,20)
    $labelUser.Size = New-Object System.Drawing.Size(280,20)
    $labelUser.ForeColor = $Primary1Color
    $textBoxUser = New-Object System.Windows.Forms.TextBox
    $textBoxUser.Location = New-Object System.Drawing.Point(10,40)
    $textBoxUser.Size = New-Object System.Drawing.Size(260,20)
    $textBoxUser.TabIndex = 0
    $textBoxUser.BackColor = $Neutral2Color
    $textBoxUser.ForeColor = $Primary1Color
    $labelPass = New-Object System.Windows.Forms.Label
    $labelPass.Text = "Password:"
    $labelPass.Location = New-Object System.Drawing.Point(10,80)
    $labelPass.Size = New-Object System.Drawing.Size(280,20)
    $labelPass.ForeColor = $Primary1Color
    $textBoxPass = New-Object System.Windows.Forms.TextBox
    $textBoxPass.Location = New-Object System.Drawing.Point(10,100)
    $textBoxPass.Size = New-Object System.Drawing.Size(260,20)
    $textBoxPass.UseSystemPasswordChar = $true
    $textBoxPass.TabIndex = 1
    $textBoxPass.BackColor = $Neutral2Color
    $textBoxPass.ForeColor = $Primary1Color
    $button = New-Object System.Windows.Forms.Button
    $button.Text = 'OK'
    $button.Location = New-Object System.Drawing.Point(10,130)
    $button.BackColor = $Secondary1Color
    $button.ForeColor = $Neutral2Color
    $button.TabIndex = 2
    $button.Add_Click({
        if ($textBoxUser.Text.Trim() -eq "" -or $textBoxPass.Text.Trim() -eq "") {
            [System.Windows.Forms.MessageBox]::Show("Both username and password are required.", "Input Required", 'OK', 'Error')
        } else {
            $Script:AdminID = $textBoxUser.Text
            $securePassword = New-Object Security.SecureString
            $textBoxPass.Text.ToCharArray() | ForEach-Object { $securePassword.AppendChar($_) }
            $Script:passwordz = $securePassword
            $form.Close()
        }
    })

    $form.Controls.Add($labelUser)
    $form.Controls.Add($textBoxUser)
    $form.Controls.Add($labelPass)
    $form.Controls.Add($textBoxPass)
    $form.Controls.Add($button)
    $form.AcceptButton = $button
    $textBoxUser.TabIndex = 0
    $textBoxPass.TabIndex = 1
    $button.TabIndex = 2

    $form.ShowDialog()
}

Show-CredentialForm


$AdminIDFile = "$WorkingPath\CYPHER\YaN.txt"
$PasswordFile = "$WorkingPath\CYPHER\Qi.txt"

function Get-SystemIdentifier {
    try {
        $motherboardInfo = Get-WmiObject Win32_BaseBoard
        if ($motherboardInfo -and $motherboardInfo.SerialNumber) {
            send-ToLog -Message "Successfully retrieved motherboard serial number." -Level "INFO"
            return $motherboardInfo.SerialNumber.Trim()
        } else {
            throw "Motherboard serial number not found."
        }
    } catch {
        send-ToLog -Message "Failed to retrieve system identifier: $_" -Level "ERROR"
        return $null
    }
}

function Crypto-SaltedKey {
    try {
        $systemIdentifier = Get-SystemIdentifier
        if (-not $systemIdentifier) {
            throw "System identifier is null or empty."
        }
        
        $hasher = [System.Security.Cryptography.SHA256]::Create()
        $salt = $hasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($systemIdentifier))
        $keyHash = $hasher.ComputeHash($salt)
        $key = $keyHash[0..15]
        
        send-ToLog -Message "Salted key generated successfully." -Level "INFO"
        return $key
    } catch {
        send-ToLog -Message "Failed to generate salted key: $_" -Level "ERROR"
        return $null
    }
}

try {
    $Key = Crypto-SaltedKey
    if (-not $Key) {
        throw "Failed to generate a valid key."
    }

    $usbPath = "$WorkingPath\CYPHER"
    $localPath = "C:\Tempest\CYPHER"
    foreach ($path in $usbPath, $localPath) {
        if (-not (Test-Path $path)) {
            New-Item -Path $path -ItemType Directory
            send-ToLog -Message "$path directory created." -Level "INFO"
        }
    }
    $secureAdminID = ConvertTo-SecureString $Script:AdminID -AsPlainText -Force
    $encryptedAdminID = $secureAdminID | ConvertFrom-SecureString -key $Key
    $encryptedAdminID | Out-File "$usbPath\YaN.txt" -ErrorAction Stop
    $encryptedAdminID | Out-File "$localPath\YaN.txt" -ErrorAction Stop
    send-ToLog -Message "Username encrypted and stored in both USB and local storage." -Level "INFO"

    $encryptedPassword = $Script:passwordz | ConvertFrom-SecureString -key $Key
    $encryptedPassword | Out-File "$usbPath\Qi.txt" -ErrorAction Stop
    $encryptedPassword | Out-File "$localPath\Qi.txt" -ErrorAction Stop
    send-ToLog -Message "Password encrypted and stored in both USB and local storage." -Level "INFO"
    
    $decryptedAdminID = Get-Content $AdminIDFile | ConvertTo-SecureString -key $Key
    $decryptedAdminID_BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decryptedAdminID)
    $plainAdminID = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($decryptedAdminID_BSTR)
    $decryptedPassword = Get-Content $PasswordFile | ConvertTo-SecureString -key $Key
    $decryptedPassword_BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decryptedPassword)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($decryptedPassword_BSTR)
    $MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $plainAdminID, $decryptedPassword
    send-ToLog -Message "Credentials reconstructed for use." -Level "INFO"

    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($decryptedAdminID_BSTR)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($decryptedPassword_BSTR)
} catch {
    send-ToLog -Message "An error occurred during the encryption process: $_" -Level "ERROR"
}


# TESTING ONLY 
# Attempt to write to a system directory
try {
    $cred = New-Object System.Management.Automation.PSCredential ($Script:AdminID, $Script:passwordz)
    Start-Process powershell -Credential $cred -ArgumentList "-NoProfile -Command `"Write-Output 'Test write access' > C:\testfile.txt`"" -Wait
    send-ToLog -Message "Admin Credential Validated: Successful Write to System Directory" -Level "INFO"
    "Successfully wrote to the system directory." | Out-File "$WorkingPath\HISTORY\DEBUG\testOutput.txt"
} catch {
    send-ToLog -Message "Credential Failed Validation: $($_.Exception.Message)" -Level "ERROR"
    $_.Exception.Message | Out-File "$WorkingPath\HISTORY\DEBUG\testError.txt"
}

function Increment-ProgressBar {
    param(
        [int]$increment  
    )

    $updateAction = [Action]{

        $Script:ProgressBar.Value += $increment

        if ($Script:ProgressBar.Value -gt $Script:ProgressBar.Maximum) {
            $Script:ProgressBar.Value = $Script:ProgressBar.Maximum
        } elseif ($Script:ProgressBar.Value -lt $Script:ProgressBar.Minimum) {
            $Script:ProgressBar.Value = $Script:ProgressBar.Minimum
        }
    }

    $Script:TEMPEST_Form.Invoke($updateAction)
}

function Minimize-CurrentWindow {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class WinApi {
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@

    $hWnd = (Get-Process -Id $PID).MainWindowHandle
    [WinApi]::ShowWindow($hWnd, 6)
}

Minimize-CurrentWindow


#None,FixedSingle,Fixed3D,FixedDialog,Sizable,FixedToolWindow,SizableToolWindow
function ShowTempestForm {
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $Script:TEMPEST_Form = New-Object System.Windows.Forms.Form
    $Script:TEMPEST_Form.TopMost = $true
    $Script:TEMPEST_Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D 
    $Script:TEMPEST_Form.Opacity = 0.99  
    $Script:TEMPEST_Form.Icon = $objIcon
    $Script:TEMPEST_Form.Text ='Daniel Estrella Advanced Powershell | TEMPEST'
    $Script:TEMPEST_Form.BackColor = $Neutral2Color
    $Script:TEMPEST_Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $Script:TEMPEST_Form.Size = '570,370'
    $Script:TEMPEST_Form.MinimizeBox = $False
    $Script:TEMPEST_Form.MaximizeBox = $False
    $Script:TEMPEST_Form.AutoSize = $False

    $iconBase64 = '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' 
    $iconBytes = [Convert]::FromBase64String($iconBase64)
    $stream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
    $Script:TEMPEST_Form.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))
    $file = Get-Item "$workingpath\CYPHER\Logo-color-05.png"
    $img = [System.Drawing.Image]::Fromfile((get-item $file))

    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Width = .15 * $img.Size.Width
    $pictureBox.Height = .15 * $img.Size.Height
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    $pictureBox.Image = $img
    $pictureBox.Location = '400,15'
    $Script:TEMPEST_Form.Controls.Add($pictureBox)

    $Script:BIG_Label = New-Object System.Windows.Forms.Label
    $Script:BIG_Label.Location = '20,20'
    $Script:BIG_Label.Size = '400,50'
    $Script:BIG_Label.Font = New-Object System.Drawing.Font("Tahoma", 30, [System.Drawing.FontStyle]::Bold)
    $Script:BIG_Label.BackColor = $Neutral2Color
    $Script:BIG_Label.ForeColor = $Primary1Color
    $Script:BIG_Label.Text = $null
    $Script:TEMPEST_Form.Controls.Add($Script:BIG_Label)

    $Script:CONNECTIONSTATUS_Label = New-Object System.Windows.Forms.Label
    $Script:CONNECTIONSTATUS_Label.Location = '25,90'
    $Script:CONNECTIONSTATUS_Label.Size = '80,20'
    $Script:CONNECTIONSTATUS_Label.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $Script:CONNECTIONSTATUS_Label.BackColor = $Neutral2Color
    $Script:CONNECTIONSTATUS_Label.ForeColor = $Secondary2Color
    $Script:TEMPEST_Form.Controls.Add($Script:CONNECTIONSTATUS_Label)

    $Script:ENCRYPTEDCREDENTIAL_Label = New-Object System.Windows.Forms.Label
    $Script:ENCRYPTEDCREDENTIAL_Label.Location = '25,110'
    $Script:ENCRYPTEDCREDENTIAL_Label.Size = '450,20'
    $Script:ENCRYPTEDCREDENTIAL_Label.Font = New-Object System.Drawing.Font("Arial", 8, [System.Drawing.FontStyle]::Bold)
    $Script:ENCRYPTEDCREDENTIAL_Label.BackColor = $Neutral2Color
    $Script:ENCRYPTEDCREDENTIAL_Label.ForeColor = $Neutral3Color
    $Script:ENCRYPTEDCREDENTIAL_Label.Text = "Credential |" + $MyCredential.username + "| has been AES Encrypted && Salted with System UUID"
    $Script:TEMPEST_Form.Controls.Add($Script:ENCRYPTEDCREDENTIAL_Label)
    
    $Script:CURRENTUSER_Label = New-Object System.Windows.Forms.Label
    $Script:CURRENTUSER_Label.Location = '105,90'
    $Script:CURRENTUSER_Label.Size = '300,35'
    $Script:CURRENTUSER_Label.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $Script:CURRENTUSER_Label.BackColor = $Neutral2Color
    $Script:CURRENTUSER_Label.ForeColor = $Primary2Color
    $Script:CURRENTUSER_Label.Text = "Current User : " + $strVal
    $Script:TEMPEST_Form.Controls.Add($Script:CURRENTUSER_Label)

    $Script:UI_Label = New-Object System.Windows.Forms.Label
    $Script:UI_Label.Location = '25,70'
    $Script:UI_Label.Size = '400,30'
    $Script:UI_Label.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $Script:UI_Label.BackColor = $Neutral2Color
    $Script:UI_Label.ForeColor = $Neutral1Color  
    $Script:UI_Label.Text = "Status: OK"
    $Script:TEMPEST_Form.Controls.Add($Script:UI_Label)

    $Script:ProgressBar = New-Object System.Windows.Forms.ProgressBar
    $Script:ProgressBar.Location = New-Object System.Drawing.Point(25, 300)  
    $Script:ProgressBar.Size = New-Object System.Drawing.Size(500, 23) 
    $Script:ProgressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Blocks  
    $Script:ProgressBar.Minimum = 0  
    $Script:ProgressBar.Maximum = 85  
    $Script:ProgressBar.Value = 0  
    $TEMPEST_Form.Controls.Add($Script:ProgressBar)

    $Script:LogTextBox = New-Object System.Windows.Forms.TextBox
    $Script:LogTextBox.Location = New-Object System.Drawing.Point(25, 130)
    $Script:LogTextBox.Size = New-Object System.Drawing.Size(500, 160)
    $Script:LogTextBox.Multiline = $true
    $Script:LogTextBox.ScrollBars = 'Vertical'
    $Script:LogTextBox.ReadOnly = $false
    $Script:LogTextBox.Font = New-Object System.Drawing.Font("Courier New", 8)
    $Script:LogTextBox.Add_KeyPress({
        $_.Handled = $true
    })
    $Script:LogTextBox.Add_MouseClick({
        $Script:LogTextBox.SelectionStart = $Script:LogTextBox.Text.Length
        $Script:LogTextBox.ScrollToCaret()
    })
    $Script:TEMPEST_Form.Controls.Add($Script:LogTextBox)
    $LogTextBox.AppendText("Init`r`n")
    $Script:LogBoxReady = $true
    $Script:TEMPEST_Form.Add_Shown({$Script:TEMPEST_Form.Activate()})

    $rs = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $rs.Open()
    $rs.SessionStateProxy.SetVariable("TEMPEST_Form", $Script:TEMPEST_Form)
    $p = $rs.CreatePipeline({ [void] $Script:TEMPEST_Form.ShowDialog() })
    $p.Input.Close()
    $p.InvokeAsync()
}

ShowTempestForm

function Update-UI {
    param(
        [string]$NetworkStatusText,
        [string]$GeneralStatusText
    )

    if ($NetworkStatusText) {
        $Script:CONNECTIONSTATUS_Label.Text = $NetworkStatusText
    }

    if ($GeneralStatusText) {
        $Script:UI_Label.Text = $GeneralStatusText
        Start-Sleep -Milliseconds 500

    }
}

                                                                                        
#_/_/_/_/                                  _/      _/                                
#_/        _/    _/  _/_/_/      _/_/_/  _/_/_/_/        _/_/    _/_/_/      _/_/_/   
#_/_/_/    _/    _/  _/    _/  _/          _/      _/  _/    _/  _/    _/  _/_/        
#_/        _/    _/  _/    _/  _/          _/      _/  _/    _/  _/    _/      _/_/     
#_/          _/_/_/  _/    _/    _/_/_/      _/_/  _/    _/_/    _/    _/  _/_/_/        
                                                                                     
                                                                                     
                                                                                

function Xcute {
    param(
        [scriptblock]$Command,
        [string]$FailureMessage,
        [string]$CheckPath,
        [string]$OperationContext
    )

    $retryCount = 0
    while ($retryCount -lt 2) {
        send-ToLog -Message "Executing command: $OperationContext." -Level "INFO"
        & $Command
        Start-Sleep -Seconds 1

        if (Test-Path $CheckPath) {
            send-ToLog -Message "Operation '$OperationContext' successful. $CheckPath confirmed." -Level "INFO"
            return $true
        } else {
            $retryCount++
            send-ToLog -Message "Attempt $retryCount Failed to confirm path: $CheckPath for '$OperationContext'. $FailureMessage" -Level "ERROR"

            if ($retryCount -ge 2) {
                $result = Show-TimedExitForm
                switch ($result) {
                    'Abort' {
                        send-ToLog -Message "User aborted the operation." -Level "ERROR"
                        $Script:TEMPEST_Form.Close()
                        Stop-Script
                        return $false
                    }
                    'Retry' {
                        send-ToLog -Message "Retrying operation '$OperationContext'." -Level "INFO"
                        $retryCount = 0  
                    }
                    Default {
                        send-ToLog -Message "Continuing despite failure in '$OperationContext'." -Level "WARNING"
                        return $false
                    }
                }
            }
        }
    }
}





function Show-TimedExitForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Command Execution Alert"
    $form.Size = New-Object System.Drawing.Size(300, 150) 
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = $Neutral2Color  
    $form.TopMost = $true
    $Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Press Exit to abort, Retry to retry or wait 30 seconds to continue."
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Size = New-Object System.Drawing.Size(250, 40)
    $label.ForeColor = $Primary1Color  
    $exitButton = New-Object System.Windows.Forms.Button
    $exitButton.Text = "Exit"
    $exitButton.Location = New-Object System.Drawing.Point(110, 60)
    $exitButton.Size = New-Object System.Drawing.Size(75, 23)
    $exitButton.BackColor = $Secondary1Color  
    $exitButton.ForeColor = $Neutral2Color 
    $exitButton.DialogResult = [System.Windows.Forms.DialogResult]::Abort

    $retryButton = New-Object System.Windows.Forms.Button
    $retryButton.Text = "Retry"
    $retryButton.Location = New-Object System.Drawing.Point(10, 60)
    $retryButton.Size = New-Object System.Drawing.Size(75, 23)
    $retryButton.BackColor = $Secondary1Color  
    $retryButton.ForeColor = $Neutral2Color  
    $retryButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry

    $form.Controls.Add($label)
    $form.Controls.Add($exitButton)
    $form.Controls.Add($retryButton)
    $form.AcceptButton = $retryButton

    
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 30000  
    $timer.Add_Tick({
        $form.DialogResult = [System.Windows.Forms.DialogResult]::None
        $form.Close()
    })
    $timer.Start()

    
    $result = $form.ShowDialog()

    $timer.Stop()
    $timer.Dispose()

    return $result
}
    
    
    


function Stop-Script {
    send-ToLog -Message "Script termination initiated by user or due to a critical failure." -Level "CRITICAL"
    Exit
    throw "Script has been terminated intentionally."
}

    function testWeb {
        do {
            $isOnline = $false

            try {
                send-ToLog -Message "Attempting to ping 8.8.8.8 to check internet connectivity." -Level "INFO"
                $ping = New-Object System.Net.NetworkInformation.Ping
                $result = $ping.Send("8.8.8.8")
                $isOnline = ($result.Status -eq "Success")
                if ($isOnline) {
                    send-ToLog -Message "Ping successful. Internet connection is active." -Level "INFO"
                } else {
                    send-ToLog -Message "Ping failed. Status: $($result.Status)" -Level "WARNING"
                }
            } catch [System.Net.NetworkInformation.PingException] {
                send-ToLog -Message "Network error: No internet connection. Details: $_" -Level "ERROR"
                $isOnline = $false
            } catch {
                send-ToLog -Message "Error encountered during ping: $_" -Level "ERROR"
                $isOnline = $false
            }

            if ($isOnline) {
                Update-UI -NetworkStatusText 'Uplink >>'
            } else {
                Update-UI -NetworkStatusText 'No Web'
                Update-UI -GeneralStatusText "UPLINK LOST PLEASE RECONNECT TO A Network! Submit Any Key in Console to Retry"
                send-ToLog -Message "UPLINK LOST. PLEASE RECONNECT TO RECONNECT TO A Network! Submit Any Key in Console to Retry" -Level "CRITICAL"
                Read-Host "UPLINK LOST PLEASE RECONNECT TO RECONNECT TO A Network! Submit Any Key in Console to Retry"
            }
        } while (-not $isOnline) 
    }





    function verifyAdmin {
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
        $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

        if ($isAdmin) {
            send-ToLog -Message "User verified as an Administrator." -Level "INFO"
        } else {
            send-ToLog -Message "You are NOT an Administrator. Preparing to log out." -Level "WARNING"
            Update-UI -GeneralStatusText "You are NOT logged in as an Administrator. You will be logged out. And script will be scheduled for next boot"


            Set-Location HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce
            New-ItemProperty . MyKey -PropertyType String -Value "Powershell.exe -executionpolicy unrestricted -file C:\Tempest\TEMPEST%1.ps1"
            send-ToLog -Message "Script Re-Scheduled to run on next boot." -Level "INFO"


            Start-Sleep -Seconds 60

            send-ToLog -Message "Logging out the user due to lack of administrator privileges. After restart, please login as Administrator" -Level "CRITICAL"
            [System.Diagnostics.Process]::Start("shutdown.exe", "/l /f")
        }
    }



    function whoAmI {
        $strVal = $env:UserName
        $CURRENTUSER_Label.Text = 'Account :' + $strVal
        send-ToLog -Message "Current user is $strVal" -Level "INFO"
    }
    

                                                                         


$BIG_Label.text="TMPst-Run%1"
testWeb
Start-Sleep 1 #just let the form breathe for a second 
send-ToLog -Message " " -ShowArt $true
$NewComputerName = "void"




function Rename_Machine {
    Update-UI -GeneralStatusText "Gathering System Information"
    whoAmI

    $CurrentComputerName = (hostname).Trim()
    $isLaptop = $null -ne (Get-WmiObject Win32_Battery)
    $type = if ($isLaptop) { "LST" } else { "DST" }

    $bios = Get-WmiObject Win32_BIOS
    $model = $bios.Version -replace ' ', ''
    $modelShort = $model.Substring(0, [Math]::Min(4, $model.Length))
    while ($modelShort.Length -lt 4) {
        $modelShort += "X"
    }

    $serial = $bios.SerialNumber -replace ' ', ''
    $adapterName = if ($isLaptop) { "Wi-Fi" } else { "Ethernet" }
    $MacAddress = (Get-NetAdapter -Name $adapterName).MacAddress -replace '-', ''
    $last6ofMac = $MacAddress.Substring($MacAddress.Length - 6)
    $NewComputerName = "$type-$modelShort-$serial-$last6ofMac"
    $expectedLength = $type.Length + 1 + $modelShort.Length + 1 + $serial.Length + 1 + $last6ofMac.Length

    Update-UI -GeneralStatusText "Checking Computer Name Necessity"
    send-ToLog -Message "Current computer name: $currentComputerName. Proposed new computer name: $NewComputerName" -Level "INFO"

    if ($NewComputerName -eq $currentComputerName) {
        Update-UI -GeneralStatusText "Rename not needed"
        send-ToLog -Message "No need to rename. This computer is already named as per the desired standard." -Level "INFO"
        return
    }

    Update-UI -GeneralStatusText "Renaming System According to New Standards"
    try {
        Rename-Computer -NewName $NewComputerName -Force
        send-ToLog -Message "This computer has been renamed to $NewComputerName." -Level "INFO"
    } catch {
        send-ToLog -Message "Failed to rename the computer: $($_.Exception.Message)" -Level "ERROR"
    }

    if ($NewComputerName.Length -ne $expectedLength) {
        send-ToLog -Message "Warning: The generated computer name may not be formatted correctly." -Level "WARNING"
        $response = Read-Host "Do you want to retry renaming? Enter 't' to try again or 'c' to continue"
        send-ToLog -Message "User response: $response" -Level "INFO"
        if ($response -eq "t") {
            Rename_Machine
        } elseif ($response -eq "c") {
            send-ToLog -Message "Continuing with the current name..." -Level "WARNING"
        }
    }
}

function map_NASDrive {
    Write-Host "Scheduling a task to map the network drive."

    $DriveLetter = "Z:"
    $NASPath = "\\192.168.0.230\share"
    $taskName = "MapNASDriveTask"
    $taskTime = (Get-Date).AddMinutes(1).ToString("HH:mm")

    try {
        schtasks.exe /Create /TN $taskName /TR "`"cmd.exe /c net use $DriveLetter $NASPath /persistent:yes`"" /SC ONCE /ST $taskTime /F /RL LIMITED /IT
        Write-Host "Scheduled task created. It will run in 1 minute."

    } catch {
        Write-Host "Exception occurred while attempting to schedule the task. Error: $_"
    }
}


function install_Chocolatey {
    Update-UI -GeneralStatusText 'Installing Chocolatey'
    
    $InstallCommand = {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    $Path = "C:\ProgramData\chocolatey\choco.exe"
    $failureMessage = "Chocolatey install appears to have failed."
    $operationContext = "Installation of Chocolatey to manage software packages easily on Windows."
    $success = Xcute -Command $InstallCommand -FailureMessage $failureMessage -CheckPath $Path -OperationContext $operationContext
    
    if (-not $success) {
        Write-Host "Failed to install Chocolatey, proceeding without it."
    }
}




function Join_Domain {
    Update-UI -GeneralStatusText "Joining Domain"
    send-ToLog -Message "Initiating process to join the Domain." -Level "INFO"
    
    testWeb
    verifyAdmin

    $DomainName = "Squeamish.Domain" 
    $Domain = (Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain

    if ($Domain) {
        send-ToLog -Message "This computer is already joined to a domain." -Level "INFO"
    } else {
        send-ToLog -Message "This Client will be joined to the domain. Computer Name: $Script:NNAME" -Level "INFO"

        try {
            Add-Computer -DomainName $DomainName -Credential $MyCredential -Force -Options JoinWithNewName,AccountCreate -Verbose -ErrorAction Stop
            send-ToLog -Message "This client has joined to the domain Successfuly." -Level "INFO"
            send-ToLog -Message "Welcome to the hive mind."
            send-ToLog -Message "Searching Active Directory for the Domain PC object to confirm Join. Please wait." -Level "INFO"
            Start-Sleep 15

            $adComputer = Get-ADComputer -Identity $Script:NNAME -Credential $MyCredential -ErrorAction Stop
            if ($adComputer) {
                send-ToLog -Message "Computer found in AD: $($adComputer.Name)" -Level "SUCCESS"
            } else {
                send-ToLog -Message "Computer not found in Active Directory." -Level "ERROR"
            }
        } catch {
            send-ToLog -Message "Error joining the domain: $_" -Level "ERROR"
        }

        send-ToLog -Message "Sleeping for 20 seconds, if there is an error in the Domain join please hit CTRL+C to exit execution." -Level "WARNING"
        0 
    }
}






function Set_FirstRestartSCRIPT {
    Update-UI -GeneralStatusText "Installing Scripts After Restart"
    verifyAdmin

    $regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    $regKey = "MyKey"
    $regValue = "Powershell.exe -noexit -executionpolicy unrestricted -file C:\Tempest\TEMPEST%2.ps1"

    try {
        Set-Location -Path $regPath

        $existingValue = Get-ItemProperty -Path . -Name $regKey -ErrorAction SilentlyContinue
        if ($existingValue) {
            Update-UI -GeneralStatusText "Registry key $regKey already exists, skipping."
            send-ToLog -Message "Registry key $regKey already exists, skipping addition." -Level "INFO"
            Set-Location $WorkingPath
        } else {

            New-ItemProperty -Path . -Name $regKey -PropertyType String -Value $regValue -Force
            send-ToLog -Message "Registry key $regKey added successfully." -Level "INFO"
            send-ToLog -Message "Next script will run after restart." -Level "INFO"
            send-ToLog -Message "Queue the sequel, this restart script is just the beginning!"
            Set-Location $WorkingPath
        }
    } catch {
        send-ToLog -Message "Error while adding or checking the registry key $regKey : $($_.Exception.Message)" -Level "ERROR"
        Set-Location $WorkingPath
    }

    Update-UI -GeneralStatusText "Finished installing Tempest."
    
}








function add_guides {
    Update-UI -GeneralStatusText "Installing Guides"
    send-ToLog -Message "Starting to install guides." -Level "INFO"

    try {
        Copy-Item -Path "$WorkingPath\LIBRARY\*" -Destination "C:\Users\Public\Desktop" -Recurse
        send-ToLog -Message "Guides have been successfully copied to Destination" -Level "INFO"
    } catch {
        send-ToLog -Message "Failed to copy guides: $_" -Level "ERROR"
    }
}




function install_DisplayLink {
    Update-UI -GeneralStatusText "Installing DisplayLink"
    send-ToLog -Message "Preparing to install DisplayLink." -Level "INFO"

    testWeb
    verifyAdmin

    $Battery = Get-WmiObject Win32_Battery | Select-Object -Property Caption | Out-String
    if ($Battery -match "Battery") {
        $installCommand = { choco install displaylink -y }
        $checkPath = "C:\ProgramData\chocolatey\lib\displaylink\tools\NIVO\DisplayLinkCore.dat"
        $failureMessage = "DisplayLink installation failed."
        $operationContext = "Installing DisplayLink, because your desk needs more cables and more monitors."

        $success = Xcute -Command $installCommand -FailureMessage $failureMessage -CheckPath $checkPath -OperationContext $operationContext

        if ($success) {
            send-ToLog -Message "DisplayLink has been successfully installed." -Level "INFO"
        } else {
            send-ToLog -Message "Failed to install DisplayLink after retry attempts or user chose to continue." -Level "ERROR"
        }
    } else {
        send-ToLog -Message "Installation not started as no battery is detected in system, which is required for DisplayLink." -Level "WARNING"
    }
}



function install_AdobeReader {
    Update-UI -GeneralStatusText "Installing Adobe Reader DC"
    send-ToLog -Message "Preparing to install Adobe Reader DC." -Level "INFO"

    testWeb
    verifyAdmin

    $installCommand = { choco install adobereader -y }
    $checkPath = "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe"
    $failureMessage = "Adobe Reader DC installation failed."
    $operationContext = "Installing Adobe Reader, to remind you why everyone hates PDFs."
    $success = Xcute -Command $installCommand -FailureMessage $failureMessage -CheckPath $checkPath -OperationContext $operationContext

    if ($success) {
        send-ToLog -Message "Adobe Reader DC has been successfully installed." -Level "INFO"
    } else {
        send-ToLog -Message "Failed to install Adobe Reader DC after retry attempts or user chose to continue." -Level "ERROR"
    }
}












function install_NotepadPlusPlus {
    testWeb
    Update-UI -GeneralStatusText "Installing Notepad++"
    $InstallCommand = { choco install notepadplusplus.install -y }
    $CheckPath = "C:\Program Files\Notepad++\notepad++.exe"
    $FailureMessage = "Notepad++ installation failed."
    $operationContext = "Installing Notepad++: For when Notepad-- just isn't enough."
    $success = Xcute -Command $InstallCommand -FailureMessage $FailureMessage -CheckPath $CheckPath -OperationContext $operationContext

    
    if ($success) {
        send-ToLog -Message "Notepad++ installed successfully." -Level "INFO"
    } else {
        send-ToLog -Message "Failed to install Notepad++ after retries." -Level "ERROR"
    }
}






function install_Scrivener {
    testWeb
    Update-UI -GeneralStatusText "Installing Scrivener: Craft your magnum opus, one page at a time"
    $InstallCommand = { choco install scrivener -y }
    $CheckPath = "C:\Program Files\Scrivener3\Scrivener.exe"
    $FailureMessage = "Scrivener installation failed."
    $operationContext = "Installing Scrivener: The ultimate tool for writers, plotting a path to your literary greatness."
    $success = Xcute -Command $InstallCommand -FailureMessage $FailureMessage -CheckPath $CheckPath -OperationContext $operationContext

    if ($success) {
        send-ToLog -Message "Scrivener installed successfully." -Level "INFO"
    } else {
        send-ToLog -Message "Failed to install Scrivener after retries." -Level "ERROR"
    }
}






function install_KLiteCodecPack {
    testWeb
    Update-UI -GeneralStatusText "Installing K-Lite Codec Pack Full"
    $InstallCommand = { choco install k-litecodecpackfull -y }
    $CheckPath = "C:\Program Files (x86)\K-Lite Codec Pack\MPC-HC64\mpc-hc64.exe"
    $FailureMessage = "K-Lite Codec Pack installation failed."
    $operationContext = "Installing K-Lite Codec Pack: Play everything, understand nothing."
    $success = Xcute -Command $InstallCommand -FailureMessage $FailureMessage -CheckPath $CheckPath -OperationContext $operationContext

    if ($success) {
        send-ToLog -Message "K-Lite Codec Pack installed successfully." -Level "INFO"
    } else {
        send-ToLog -Message "Failed to install K-Lite Codec Pack after retries." -Level "ERROR"
    }
}





# function install_PowerBI {
#     Update-UI -GeneralStatusText "Installing Power BI Desktop"
#     $InstallCommand = {choco install powerbi -y }
#     $CheckPath = "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
#     $FailureMessage = "Power BI Desktop installation failed."
#     $operationContext = "Installing Power BI, because you apparently enjoy visualizing your suffering."
#     $success = Xcute -Command $InstallCommand -FailureMessage $FailureMessage -CheckPath $CheckPath -OperationContext $operationContext

#     if ($success) {
#         send-ToLog -Message "Power BI Desktop installed successfully." -Level "INFO"
#     } else {
#         send-ToLog -Message "Failed to install Power BI Desktop after retries." -Level "ERROR"
#     }
# }



function install_Twingate {
    testWeb
    Update-UI -GeneralStatusText "Installing Twingate"
    $InstallCommand = { choco install twingate -y }
    $CheckPath = "C:\Program Files\Twingate\Twingate.exe"
    $FailureMessage = "Twingate installation failed."
    $operationContext = "Installing Twingate, because security is no joke (but your password might be)."
    $success = Xcute -Command $InstallCommand -FailureMessage $FailureMessage -CheckPath $CheckPath -OperationContext $operationContext

    if ($success) {
        send-ToLog -Message "Twingate installed successfully." -Level "INFO"
    } else {
        send-ToLog -Message "Failed to install Twingate after retries." -Level "ERROR"
    }
}




function setup_YT-DLP_Config {
    Update-UI -GeneralStatusText "Configuring yt-dlp"
    $configDirectory = "$env:APPDATA\yt-dlp"
    $configFile = "config.txt"
    $configContent = @"
--no-mtime
--restrict-filenames
--trim-filenames 50
--ffmpeg-location "C:\ProgramData\chocolatey\lib\ffmpeg\tools\ffmpeg\bin"
--output "~/Videos/%(title)s.%(ext)s"
--format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best"
--merge-output-format mp4
"@

    $operationContext = "Setting up yt-dlp config file."

    try {
        if (-Not (Test-Path $configDirectory)) {
            New-Item -Path $configDirectory -ItemType Directory -Force
            send-ToLog -Message "Created directory for yt-dlp config: $configDirectory" -Level "INFO"
        }

        $configFilePath = "$configDirectory\$configFile"
        Set-Content -Path $configFilePath -Value $configContent -Force
        send-ToLog -Message "yt-dlp config file created at $configFilePath. $operationContext" -Level "INFO"
    } catch {
        send-ToLog -Message "Failed to create yt-dlp config file. $operationContext Error: $_" -Level "ERROR"
    }
}



function Deploy-StartMenuLayout {
    param(
        [string]$sourcePath,  
        [string]$deploymentRoot = "$env:SystemDrive\Users"  
    )

    Update-UI -GeneralStatusText "Deploying Start Menu Layout"
    send-ToLog -Message "Starting deployment of Start Menu layout." -Level "INFO"
    $defaultUserPath = Join-Path -Path $deploymentRoot -ChildPath "Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
    if (Test-Path -Path $defaultUserPath) {
        Copy-Item -Path $sourcePath -Destination $defaultUserPath -Force
        send-ToLog -Message "Start Menu layout deployed to Default User profile." -Level "INFO"
    } else {
        send-ToLog -Message "Default User profile not found. Skipping this profile." -Level "WARNING"
    }
    Get-ChildItem -Path $deploymentRoot -Directory | ForEach-Object {
        $userStartMenuPath = Join-Path -Path $_.FullName -ChildPath "AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
        if (Test-Path -Path $userStartMenuPath) {
            Copy-Item -Path $sourcePath -Destination $userStartMenuPath -Force
            send-ToLog -Message "Start Menu layout deployed to user profile: $($_.Name)" -Level "INFO"
        } else {
            send-ToLog -Message "Start Menu path not found for user profile: $($_.Name). Skipping this profile." -Level "WARNING"
        }
    }
    Get-Process -Name Explorer | Stop-Process -Force
    Start-Process -FilePath "explorer.exe"
    send-ToLog -Message "Windows Explorer restarted to apply layout changes." -Level "INFO"
}



function multi_Tool {
    

    Update-UI -GeneralStatusText "Configuring Wallpaper for all users"
    send-ToLog -Message "Multi-Tool: Because why do one thing well when you can do many poorly?"

    Update-UI -GeneralStatusText "Configuring Tempest Custom Files and Directories"

    $directoryPath = "C:\Tempest"
    if (-not (Test-Path $directoryPath)) {
        New-Item -Path $directoryPath -ItemType Directory
        send-ToLog -Message "Tempest directory created." -Level "INFO"
    } else {
        send-ToLog -Message "Tempest directory already exists, skipping creation." -Level "INFO"
    }

     $layoutPinSource = "$WorkingPath\CYPHER\Layout\LayoutPin.xml"
     $layoutPinDest = "$directoryPath\LayoutPin.xml"
     if (-not (Test-Path $layoutPinDest)) {
         Copy-Item $layoutPinSource -Destination $layoutPinDest
         send-ToLog -Message "LayoutPin.xml copied to Tempest directory." -Level "INFO"
     } else {
         send-ToLog -Message "LayoutPin.xml already exists in Tempest directory, skipping copy." -Level "INFO"
     }
 

     try {
         Import-StartLayout -LayoutPath $layoutPinDest -MountPath "C:\"  
         send-ToLog -Message "Start layout imported successfully from $layoutPinDest." -Level "INFO"
     } catch {
         send-ToLog -Message "Failed to import start layout: $_" -Level "ERROR"
     }

     $start2Path = "$directoryPath\start2.bin"
     if (-not (Test-Path $start2Path)) {
         Copy-Item "$WorkingPath\CYPHER\Layout\start2.bin" -Destination $directoryPath
         send-ToLog -Message "start2.bin copied to Tempest directory." -Level "INFO"
     } else {
         send-ToLog -Message "start2.bin already exists in Tempest directory, skipping copy." -Level "INFO"
     }
     

    $scrptCache = "$directoryPath\TEMPEST%1.ps1"
    if (-not (Test-Path $scrptCache)) {
        Copy-Item "$WorkingPath\TEMPEST%1.ps1" -Destination $directoryPath
        send-ToLog -Message "TEMPEST%1 Script copied to Tempest directory." -Level "INFO"
    } else {
        send-ToLog -Message "TEMPEST%1 already exists, skipping copy." -Level "INFO"
    }

    $scrptCache2 = "$directoryPath\TEMPEST%2.ps1"
    if (-not (Test-Path $scrptCache2)) {
        Copy-Item "$WorkingPath\TEMPEST%2.ps1" -Destination $directoryPath
        send-ToLog -Message "TEMPEST%2 Script copied to Tempest directory." -Level "INFO"
    } else {
        send-ToLog -Message "TEMPEST%2 already exists, skipping copy." -Level "INFO"
    }

    $cypherPath = "$directoryPath\CYPHER"
    if (-not (Test-Path $cypherPath)) {
        New-Item -Path $cypherPath -ItemType Directory
        send-ToLog -Message "Cypher directory created in Tempest directory." -Level "INFO"
    }

    $GPSpath = "$cypherPath\GPS.txt"
    $GPSdata | Out-File $GPSpath
    send-ToLog -Message "Data written to GPS.txt in Cypher directory." -Level "INFO"

    $imagePath = "$WorkingPath\CYPHER\Logo-color-05.png"
    if (Test-Path $imagePath) {
        $destination = "$cypherPath\Logo-color-05.png"
        Copy-Item $imagePath -Destination $destination
        send-ToLog -Message "Logo image copied to Cypher directory." -Level "INFO"
    } else {
        send-ToLog -Message "Logo image not found in the working path, skipping copy." -Level "ERROR"
    }

    $imagePath2 = "$WorkingPath\Package\tempest_bg.jpg"
    if (Test-Path $imagePath2) {
        $destination2 = "$directoryPath\tempest_bg.jpg"
        Copy-Item $imagePath2 -Destination $destination2
        send-ToLog -Message "Desktop Background image copied to Tempest directory." -Level "INFO"
    } else {
        send-ToLog -Message "Desktop Background image not found in the working path, skipping copy." -Level "ERROR"
    }
    
    
    Update-UI -GeneralStatusText "Configuring Start Menu and Taskbar"
    $Management = Get-Item $directoryPath -Force
    $Management.attributes = 'Hidden'
    Update-UI -GeneralStatusText "Concealing Tempest Custom Files"
    send-ToLog -Message "Tempest custom files directory set to hidden." -Level "INFO"
    


    $assocFile = "C:\Tempest\Assoc.xml"
    if (-not (Test-Path $assocFile)) {
        Copy-Item "$WorkingPath\CYPHER\Assoc\Assoc.xml" -Destination $directoryPath
        send-ToLog -Message "Assoc file copied to Tempest directory." -Level "INFO"
    } else {
        Update-UI -GeneralStatusText "Assoc file already exists, skipping."
        send-ToLog -Message "Assoc file already exists, skipping copy." -Level "INFO"
        
    }
   
    & "$WorkingPath\PACKAGE\LGPO_30\LGPO.exe" /g "$WorkingPath\CYPHER\GPO" /v
    Update-UI -GeneralStatusText "Synchronising Policy Configurations"
    Send-ToLog -Message "Policy configurations synchronized using LGPO." -Level "INFO"
    $Management = Get-Item $directoryPath -Force
    $Management.attributes = 'Hidden'
    Update-UI -GeneralStatusText "Concealing Tempest Custom Files"
    send-ToLog -Message "Tempest custom files directory set to hidden." -Level "INFO"
    
}



function dark_Theme {
    Update-UI -GeneralStatusText "Configuring Dark Mode and applying custom theme for system and taskbar"
    $themeDirectory = "C:\Tempest\Theme"
    $themeFile = "CustomDark.theme"
    $sourceThemePath = "$WorkingPath\PACKAGE\Theme\$themeFile"
    $destinationThemePath = "$themeDirectory\$themeFile"
    $operationContext = "Applying custom theme."

    if (-Not (Test-Path $themeDirectory)) {
        New-Item -Path $themeDirectory -ItemType Directory
    }

    if (Test-Path $sourceThemePath) {
        Copy-Item -Path $sourceThemePath -Destination $destinationThemePath -Force
    } else {
        send-ToLog -Message "Theme file not found at $sourceThemePath." -Level "ERROR"
        return
    }

    try {
        Start-Process -FilePath $destinationThemePath
        send-ToLog -Message "Custom theme applied immediately to current user. $operationContext" -Level "INFO"

        Get-Process -Name "SystemSettings" | Stop-Process -Force
        send-ToLog -Message "Closed the Settings app to prevent disruption." -Level "INFO"


        $defaultUserHive = "$env:SystemDrive\Users\Default\NTUSER.DAT"
        if (Test-Path $defaultUserHive) {
            REG LOAD "HKU\Default" $defaultUserHive
            REG ADD "HKU\Default\Software\Microsoft\Windows\CurrentVersion\Themes" /v "CurrentTheme" /t REG_SZ /d $destinationThemePath /f
            REG UNLOAD "HKU\Default"
            send-ToLog -Message "Theme file set as default for new user profiles successfully. $operationContext" -Level "INFO"
        } else {
            send-ToLog -Message "Default user profile hive not found. Cannot set theme as default for new users." -Level "ERROR"
        }
    } catch {
        send-ToLog -Message "Failed to apply custom theme. $operationContext Error: $_" -Level "ERROR"
    }
}


function Set-WindowsCopilot {
    Update-UI -GeneralStatusText "Setting Windows Copilot Policy"
    Start-Sleep -Seconds 2

    $keyPath = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'
    $valueName = 'TurnOffWindowsCopilot'
    $valueData = 1
    $operationContext = "Setting Windows Copilot Policy"

    if (-not (Test-Path $keyPath)) {
        try {
            New-Item -Path $keyPath -Force | Out-Null
            send-ToLog -Message "Created registry key: $keyPath" -Level "INFO"
        } catch {
            send-ToLog -Message "Failed to create registry key: $keyPath. $operationContext Error: $_" -Level "ERROR"
            Update-UI -GeneralStatusText "Failed to set Windows Copilot policy."
            return
        }
    }

    try {
        $existingValue = Get-ItemProperty -Path $keyPath -Name $valueName -ErrorAction SilentlyContinue
        if ($null -ne $existingValue) {
            send-ToLog -Message "Registry value $valueName already exists. Ensuring it is set correctly." -Level "INFO"
        }

        Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -Type DWord
        send-ToLog -Message "Set registry value $valueName to $valueData in $keyPath." -Level "INFO"
    } catch {
        send-ToLog -Message "Failed to set Windows Copilot policy: $($_.Exception.Message)" -Level "ERROR"
        Update-UI -GeneralStatusText "Failed to set Windows Copilot policy."
        return
    }

    Update-UI -GeneralStatusText "Windows Copilot policy setting complete."
    Start-Sleep -Seconds 2
}

function Hide-SearchFromTaskbar {
    Update-UI -GeneralStatusText "Hiding the search box from the taskbar"
    Start-Sleep -Seconds 2

    $keyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    $valueName = 'SearchboxTaskbarMode'
    $valueData = 0
    $operationContext = "Hiding search box from taskbar"

    try {
        if (-not (Test-Path $keyPath)) {
            New-Item -Path $keyPath -Force | Out-Null
            send-ToLog -Message "Created registry key: $keyPath" -Level "INFO"
        }

        Set-ItemProperty -Path $keyPath -Name $valueName -Value $valueData -Type DWord
        send-ToLog -Message "Set registry value $valueName to $valueData in $keyPath. Search box is hidden from taskbar." -Level "INFO"

    } catch {
        send-ToLog -Message "Failed to hide search box from taskbar: $($_.Exception.Message)" -Level "ERROR"
        Update-UI -GeneralStatusText "Failed to hide search box from taskbar."
        return
    }

    Update-UI -GeneralStatusText "Search box has been successfully hidden from the taskbar."
    Start-Sleep -Seconds 2
}

function Remove-WindowsWidgets {
    Update-UI -GeneralStatusText "Removing Windows 11 widgets..."
    Start-Sleep -Seconds 2

    $operationContext = "Removing Windows 11 widgets"

    try {
        send-ToLog -Message "Starting removal of widgets package from existing user accounts." -Level "INFO"
        Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "*WebExperience*"} | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        send-ToLog -Message "Successfully removed widgets package from existing user accounts." -Level "INFO"
        send-ToLog -Message "Starting removal of provisioned widgets package for new users." -Level "INFO"
        $AppxRemoval = Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*WebExperience*"}
        ForEach ($App in $AppxRemoval) {
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName
        }
        send-ToLog -Message "Successfully removed provisioned widgets package for new user accounts." -Level "INFO"

    } catch {
        send-ToLog -Message "Failed to remove Windows 11 widgets. $operationContext Error: $($_.Exception.Message)" -Level "ERROR"
        Update-UI -GeneralStatusText "Failed to remove Windows 11 widgets."
        return
    }

    Update-UI -GeneralStatusText "Windows 11 widgets have been successfully removed."
    Start-Sleep -Seconds 2
}


function Remove-OneDrive {
    Update-UI -GeneralStatusText "Uninstalling OneDrive..."
    Start-Sleep -Seconds 2

    $operationContext = "Uninstalling OneDrive"

    try {
        Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force
        send-ToLog -Message "OneDrive process terminated." -Level "INFO"
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            send-ToLog -Message "Winget is available. Proceeding with OneDrive uninstallation." -Level "INFO"

            try {
                winget uninstall 'Microsoft.OneDrive' -h --accept-source-agreements
                send-ToLog -Message "Successfully uninstalled OneDrive using winget." -Level "INFO"
            } catch {
                send-ToLog -Message "Failed to uninstall OneDrive using winget. Error: $($_.Exception.Message)" -Level "ERROR"
            }

            try {
                winget uninstall 'Microsoft OneDrive' -h --accept-source-agreements
                send-ToLog -Message "Successfully uninstalled 'Microsoft One Drive' using winget." -Level "INFO"
            } catch {
                send-ToLog -Message "Failed to uninstall 'Microsoft One Drive' using winget. Error: $($_.Exception.Message)" -Level "ERROR"
            }

            try {
                Get-Process -Name Explorer | Stop-Process -Force
                Start-Process -FilePath "explorer.exe"
                send-ToLog -Message "Explorer restarted after OneDrive uninstallation." -Level "INFO"
            } catch {
                send-ToLog -Message "Failed to restart Explorer. Error: $($_.Exception.Message)" -Level "ERROR"
            }

        } else {
            send-ToLog -Message "Winget is not available. Unable to proceed with OneDrive uninstallation." -Level "ERROR"
            Update-UI -GeneralStatusText "Failed to uninstall OneDrive due to missing winget."
            return
        }

    } catch {
        send-ToLog -Message "An unexpected error occurred during the OneDrive uninstallation process. $operationContext Error: $($_.Exception.Message)" -Level "ERROR"
        Update-UI -GeneralStatusText "Failed to uninstall OneDrive."
        return
    }

    Update-UI -GeneralStatusText "OneDrive uninstallation completed successfully."
    Start-Sleep -Seconds 2
}

function Enable_FullContextMenu {
    Update-UI -GeneralStatusText 'Enabling Full Context Menu (Make Win 11 Bearable)'
    send-ToLog -Message "Starting the registry modification process to enable the full context menu." -Level "INFO"

    $keyPath = "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"

    function Test_RegistryKeyExists {
        param([string]$path)
        return Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
    }

    if (Test_RegistryKeyExists $keyPath) {
        Update-UI -GeneralStatusText "Registry key exists, deleting it to restore full context menu."
        send-ToLog -Message "Registry key exists. Deleting the condensed context menu key." -Level "INFO"
        
        $result = reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
        if ($LASTEXITCODE -ne 0) {
            send-ToLog -Message "Failed to delete registry key: $result" -Level "ERROR"
            return
        }
    } else {
        Update-UI -GeneralStatusText "Registry key not found, creating key to show full context menu."
        send-ToLog -Message "Registry key not found. Creating the registry key to always show the full context menu." -Level "INFO"

        $result = reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /d "" /f
        if ($LASTEXITCODE -ne 0) {
            send-ToLog -Message "Failed to create registry key: $result" -Level "ERROR"
            return
        }
    }

    send-ToLog -Message "Successfully enabled full context menu." -Level "INFO"
    Update-UI -GeneralStatusText "Successfully enabled full context menu."
}






function Dell_Command_Update {
    Update-UI -GeneralStatusText "System Driver Inspection"
    send-ToLog -Message "Starting the manufacturer identification process." -Level "INFO"

    testWeb
    verifyAdmin

    $Manufacturer = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer

    if ($Manufacturer -match "Dell Inc.") {
        Update-UI -GeneralStatusText "Dell Detected. Installing Dell Command Update"
        send-ToLog -Message "The computer is manufactured by Dell. Installing Dell Command Update." -Level "INFO"

        $installCommand = { choco install dellcommandupdate -y }
        $checkPath = "C:\Program Files (x86)\Dell\CommandUpdate\DellCommandUpdate.exe"
        $failureMessage = "Dell Command Update installation failed."
        $operationContext = "Installing Dell Command Update, because your drivers need more drama."  
        $success = Xcute -Command $installCommand -FailureMessage $failureMessage -CheckPath $checkPath -OperationContext $operationContext

        if (!$success) {
            send-ToLog -Message "Failed to install Dell Command Update after retry attempts or user chose to continue." -Level "ERROR"
        }
    } elseif ($Manufacturer -match "LENOVO") {
        Update-UI -GeneralStatusText "Lenovo Detected. Installing Lenovo System Update"
        send-ToLog -Message "The computer is manufactured by Lenovo. Installing Lenovo's System Update." -Level "INFO"

        $installCommand = { choco install lenovo-thinkvantage-system-update -y }
        $checkPath = "C:\Program Files\Lenovo\System Update\TvsuCommandLauncher.exe"
        $failureMessage = "Lenovo's System Update installation failed."
        $operationContext = "Lenovo Driver Tool: Because apparently, Lenovo knows best."
        $success = Xcute -Command $installCommand -FailureMessage $failureMessage -CheckPath $checkPath -OperationContext $operationContext

        if (!$success) {
            send-ToLog -Message "Failed to install Lenovo's System Update after retry attempts or user chose to continue." -Level "ERROR"
        }
    } else {
        Update-UI -GeneralStatusText "Manufacturer not supported for automated updates."
        send-ToLog -Message "The computer is not manufactured any identifiable manufacturer. No specific driver utility programs will be installed." -Level "INFO"
    }

    Start-Sleep 5
}



function endscript {
    Update-UI -GeneralStatusText "Rebooting"
    send-ToLog -Message "Initiating system reboot sequence." -Level "INFO"
    verifyAdmin

    $LogBoxReady = $False
    $TEMPEST_Form.Close()
    send-ToLog -Message "Main form closed." -Level "INFO"


    if ($rs) {
        $rs.Close()
        send-ToLog -Message "Asynchronous compute pipe closed." -Level "INFO"
    }

    send-ToLog -Message "Executing reboot command." -Level "INFO"
    cmd.exe /c "shutdown /r /t 10"
    send-ToLog -Message " " -ShowArt $true
    $response = Read-Host "System will reboot in 10 seconds Press 'a' to abort, or any key to reboot now"
    send-ToLog -Message "User response received: $response" -Level "INFO"

    if ($response -eq "a") {
        cmd.exe /c "shutdown /a"
        send-ToLog -Message "Reboot aborted by user." -Level "INFO"
    } else {
        send-ToLog -Message "System will reboot in 1 second." -Level "INFO"
        cmd.exe /c "shutdown /r /t 1"
        Stop-Transcript
        send-ToLog -Message "Transcript stopped and system is rebooting." -Level "INFO"
        send-ToLog -Message " " -ShowArt $true
        send-ToLog -Message "End Script: Congrats, you've survived. Now go pretend everything works perfectly."

        
    }
}



#    _/_/_/_/                                    _/                
#   _/        _/      _/    _/_/    _/_/_/    _/_/_/_/    _/_/_/   
#  _/_/_/    _/      _/  _/_/_/_/  _/    _/    _/      _/_/        
# _/          _/  _/    _/        _/    _/    _/          _/_/     
#_/_/_/_/      _/        _/_/_/  _/    _/      _/_/  _/_/_/ 



#Modifications
Rename_Machine
map_NASDrive
multi_Tool
dark_Theme
Set_FirstRestartSCRIPT
Enable_FullContextMenu
setup_YT-DLP_Config

#Series Installs
install_chocolatey
install_NotepadPlusPlus
Dell_Command_Update
install_Scrivener
install_AdobeReader
install_KLiteCodecPack
install_DisplayLink
install_Twingate
# #install_PowerBI


$logFilePath = "$WorkingPath\install_jobs_log.txt"
$jobs = @()
$installCommands = @(
    @{ Command = { choco install officeproplus2013 -y }; Label = 'officeproplus2013' },
    @{ Command = { choco install powertoys -y }; Label = 'powertoys' },
    @{ Command = { choco install pycharm-community -y }; Label = 'pycharm-community' },
    @{ Command = { choco install googlechrome -y }; Label = 'googlechrome' },
    @{ Command = { choco install brave -y }; Label = 'brave' },
    @{ Command = { choco install audacity -y }; Label = 'audacity' },
    @{ Command = { choco install python3 -y }; Label = 'python3' },
    @{ Command = { choco install git -y }; Label = 'git' },
    @{ Command = { choco install vscode -y }; Label = 'vscode' },
    @{ Command = { choco install firefox -y }; Label = 'firefox' },
    @{ Command = { choco install vlc -y }; Label = 'vlc' },
    @{ Command = { choco install teamviewer -y }; Label = 'teamviewer' },
    @{ Command = { choco install ccleaner -y }; Label = 'ccleaner' },
    @{ Command = { choco install zoom -y }; Label = 'zoom' },
    @{ Command = { choco install slack -y }; Label = 'slack' },
    @{ Command = { choco install nodejs -y }; Label = 'nodejs' },
    @{ Command = { choco install ffmpeg -y }; Label = 'ffmpeg' },
    @{ Command = { choco install 7zip -y }; Label = '7zip' },
    @{ Command = { choco install yt-dlp -y }; Label = 'yt-dlp' },
    @{ Command = { choco install putty.install -y }; Label = 'putty install' }
)
$maxConcurrentJobs = 10

function Add-Job {
    param (
        [scriptblock]$Command,
        [string]$Label
    )

   
    $uniqueLabel = "$Label-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    $newJob = Start-Job -ScriptBlock $Command -Name $uniqueLabel
    $global:jobs += @{ Job = $newJob; Label = $uniqueLabel }
    Write-Output "Started new job: $($newJob.Id) - $uniqueLabel"
}

function Clean-Up-Jobs {
    $completedJobs = $global:jobs | Where-Object { $_.Job.State -eq 'Completed' -or $_.Job.State -eq 'Failed' }
    foreach ($completedJob in $completedJobs) {
        $job = $completedJob.Job
        $label = $completedJob.Label

        $output = Receive-Job -Job $job -ErrorAction SilentlyContinue
        $errorr = $job.ChildJobs[0].Error | Out-String

        if ($job.State -eq 'Completed' -and !$errorr) {
            Write-Output "Job $($job.Id) ($label) completed successfully."
            Add-Content -Path $logFilePath -Value "Job $($job.Id) ($label) completed successfully.`r`n$output`r`n"
        } else {
            Write-Output "Job $($job.Id) ($label) failed or encountered an issue."
            Add-Content -Path $logFilePath -Value "Job $($job.Id) ($label) failed with error:`r`n$error`r`n"
        }

        Remove-Job -Job $job
        $global:jobs = $global:jobs | Where-Object { $_.Job.Id -ne $job.Id }
    }
}

foreach ($installCommand in $installCommands) {
    while ($jobs.Count -ge $maxConcurrentJobs) {
        Clean-Up-Jobs
        Start-Sleep -Seconds 5
    }

    Add-Job -Command $installCommand.Command -Label $installCommand.Label
}

while ($jobs.Count -gt 0) {
    Clean-Up-Jobs
    Start-Sleep -Seconds 5
}

Write-Output "All parallel jobs completed."
Add-Content -Path $logFilePath -Value "All parallel jobs completed.`r`n"




#Post Script Cleanup and Final Modifications

Remove-WindowsWidgets

Remove-OneDrive

Deploy-StartMenuLayout -sourcePath "C:\Tempest\Start2.bin"

Set-WindowsCopilot

Hide-SearchFromTaskbar

endscript