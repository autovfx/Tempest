#VERSION 0.0.0.1
#Name: TEMPEST%2.ps1
#DEV:Daniel Estrella



Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$WorkingPath = "C:\Tempest"
$LogBoxReady = $False

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




$GPSdata = "$WorkingPath\CYPHER\GPS.txt"





#Color Guide
$Primary1Color = [System.Drawing.Color]::FromArgb(0, 71, 171)  
$Primary2Color = [System.Drawing.Color]::FromArgb(135, 206, 235)  
$Secondary1Color = [System.Drawing.Color]::FromArgb(255, 69, 0) 
$Secondary2Color = [System.Drawing.Color]::FromArgb(0, 255, 0)  
$Secondary3Color = [System.Drawing.Color]::FromArgb(0, 128, 128)  
$Neutral1Color = [System.Drawing.Color]::FromArgb(150, 150, 150)  
$Neutral2Color = [System.Drawing.Color]::FromArgb(254, 254, 254)  
$Neutral3Color = [System.Drawing.Color]::FromArgb(30, 30, 30)




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






$PasswordFile = "$WorkingPath\CYPHER\Qi.txt"
$AdminIDFile = "$WorkingPath\CYPHER\YaN.txt"

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
    
    $encryptedAdminID = Get-Content $AdminIDFile -ErrorAction Stop
    $decryptedAdminID = ConvertTo-SecureString -String $encryptedAdminID -Key $Key
    $AdminID_BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decryptedAdminID)
    $plainAdminID = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($AdminID_BSTR)
    
    send-ToLog -Message "Username decrypted successfully." -Level "INFO"
} catch {
    send-ToLog -Message "Failed to decrypt username: $_" -Level "ERROR"
    $plainAdminID = $null
}

try {
    $encryptedPassword = Get-Content $PasswordFile -ErrorAction Stop
    $decryptedPassword = ConvertTo-SecureString -String $encryptedPassword -Key $Key
    $Password_BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decryptedPassword)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Password_BSTR)
    
    send-ToLog -Message "Password decrypted successfully." -Level "INFO"
} catch {
    send-ToLog -Message "Failed to decrypt password: $_" -Level "ERROR"
    $plainPassword = $null
}

if ($plainAdminID -and $decryptedPassword) {
    $MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $plainAdminID, $decryptedPassword
    send-ToLog -Message "Credential object created successfully." -Level "INFO"
} else {
    send-ToLog -Message "Failed to create credential object due to previous errors." -Level "ERROR"
}





$debugPath = "$WorkingPath\HISTORY\DEBUG"



if (-not (Test-Path $debugPath)) {
    New-Item -Path $debugPath -ItemType Directory -Force | Out-Null
}

"System Identifier: $systemIdentifier" | Out-File "$debugPath\SystemID.txt"
"Salted Key for Decryption: $($Key -join ',')" | Out-File "$debugPath\SaltedKeyforDecrypt.txt" -Append
"Decrypted Username: $plainAdminID" | Out-File "$debugPath\DecryptedUsername.txt" -Append
"Decrypted Password: $plainPassword" | Out-File "$debugPath\DecryptedPassword.txt" -Append
"Complete Credential Object: $plainAdminID, $plainPassword" | Out-File "$debugPath\FullCredentialDecrypted.txt"






try {
    Start-Process powershell -Credential $MyCredential -ArgumentList "-NoProfile -Command `Write-Output 'Test write access' > C:\testfile.txt`"" -Wait
    send-ToLog -Message "Admin Credential Validated: Successful Write to System Directory" -Level "INFO"
    "Successfully wrote to the system directory." | Out-File "$WorkingPath\HISTORY\DEBUG\testOutput.txt"
} catch {
    send-ToLog -Message "Credential Failed Validation: $($_.Exception.Message)" -Level "ERROR"
    $_.Exception.Message | Out-File "$WorkingPath\HISTORY\DEBUG\testError.txt"
}




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

    $iconBase64 = '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'  # The base64 string for the icon
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
    $Script:ProgressBar.Maximum = 158  
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



function Xcute{
    param(
        [scriptblock]$Command,
        [string]$FailureMessage,
        [string]$CheckPath,
        [string]$OperationContext  
    )
    
    do {
        send-ToLog -Message "Executing command: $OperationContext." -Level "INFO"
        & $Command
        Start-Sleep -Seconds 1

        if (Test-Path $CheckPath) {
            send-ToLog -Message "Operation '$OperationContext' successful. $CheckPath confirmed." -Level "INFO"
            return $true
        } else {
            send-ToLog -Message "Failed to confirm path: $CheckPath for '$OperationContext'. $FailureMessage" -Level "ERROR"
            $response = Read-Host "Failed 'T' to try again or 'C' to continue"
            send-ToLog -Message "User response: $response" -Level "INFO"
            
            if ($response.ToLower() -eq 'c') {
                send-ToLog -Message "Continuing despite failure in '$OperationContext'." -Level "WARNING"
                return $false
            }
        }
    } while ($response.ToLower() -eq 't')
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
        New-ItemProperty . MyKey -PropertyType String -Value "Powershell.exe -executionpolicy unrestricted -file C:\TEMPEST%1.ps1"
        send-ToLog -Message "Script Re-Scheduled to run on next boot." -Level "INFO"


        Start-Sleep -Seconds 60

        send-ToLog -Message "Logging out the user due to lack of administrator privileges. After restart, please login as Administrator" -Level "CRITICAL"
        [System.Diagnostics.Process]::Start("shutdown.exe", "/l /f")
    }
}



function whoAmI {
    $strVal = $env:UserName
    $Script:CURRENTUSER_Label = 'Account :' + $strVal
    send-ToLog -Message "Current user is $strVal" -Level "INFO"
}


function Remove-TempestData {
    Update-UI -GeneralStatusText "Destroying AES256 Salted && Encrypted Credentials"
    
    VerifyAdmin

    
    $pathsToRemove = @(
        "$WorkingPath\CYPHER\Qi.txt",
        "$WorkingPath\CYPHER\YaN.txt",
        "$WorkingPath\CYPHER\GPS.txt"
    )
    
    foreach ($path in $pathsToRemove) {
        if (Test-Path $path) {
            Remove-Item $path -Force
            send-ToLog -Message "Removed file: $path" -Level "INFO"
        } else {
            send-ToLog -Message "File not found, cannot remove: $path" -Level "WARNING"
        }
    }
}



function Final_Restart {
    send-ToLog -Message " " -ShowArt $true
    send-ToLog -Message "Tempest has Completed"
    Update-UI -GeneralStatusText "Tempest has Completed"

    $confirmForm = New-Object System.Windows.Forms.Form
    $confirmForm.Text = 'Reboot Confirmation'
    $confirmForm.Size = New-Object System.Drawing.Size(400, 150)
    $confirmForm.StartPosition = 'CenterScreen'
    $confirmForm.BackColor = $Neutral2Color
    $confirmForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $confirmForm.TopMost = $true  
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Press 'Y' to reboot or 'N' to cancel."
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(380, 20)
    $label.ForeColor = $Primary1Color

    $buttonNo = New-Object System.Windows.Forms.Button
    $buttonNo.Text = 'No'
    $buttonNo.Location = New-Object System.Drawing.Point(205, 80)
    $buttonNo.Size = New-Object System.Drawing.Size(75, 23)
    $buttonNo.BackColor = $Secondary1Color
    $buttonNo.ForeColor = $Neutral2Color
    $buttonNo.DialogResult = [System.Windows.Forms.DialogResult]::No

    $buttonYes = New-Object System.Windows.Forms.Button
    $buttonYes.Text = 'Yes'
    $buttonYes.Location = New-Object System.Drawing.Point(120, 80)
    $buttonYes.Size = New-Object System.Drawing.Size(75, 23)
    $buttonYes.BackColor = $Secondary1Color
    $buttonYes.ForeColor = $Neutral2Color
    $buttonYes.DialogResult = [System.Windows.Forms.DialogResult]::Yes

    $confirmForm.Controls.Add($label)
    $confirmForm.Controls.Add($buttonNo)
    $confirmForm.Controls.Add($buttonYes)
    $confirmForm.CancelButton = $buttonNo
    $confirmForm.AcceptButton = $buttonYes

    $confirmForm.KeyPreview = $true
    $confirmForm.Add_KeyDown({
        if ($_.KeyCode -eq 'Y') {
            $buttonYes.PerformClick()
        }
        elseif ($_.KeyCode -eq 'N') {
            $buttonNo.PerformClick()
        }
    })

    $confirmForm.Add_Shown({$confirmForm.Activate()})

    $result = $confirmForm.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        send-ToLog -Message "System is rebooting..." -Level "INFO"
        Start-Sleep -Seconds 1  
        [System.Diagnostics.Process]::Start("cmd.exe", "/c shutdown /r /t 1")
    } else {
        send-ToLog -Message "Shutdown canceled by user." -Level "INFO"
    }

    $Script:TEMPEST_Form.Close()
    Stop-Transcript
    Exit
    throw "Script has been terminated intentionally."
}


$Script:BIG_Label.text="TMPst-Run%2"
Start-Sleep 1
whoAmI
send-ToLog -Message " " -ShowArt $true
testWeb                                                         
Start-sleep 1
Remove-TempestData
Final_Restart








