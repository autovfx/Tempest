# Tempest
Tempest Windows Provisioning. Use it as a base framework for your windows configuration deployments. 



Invoke-WebRequest -Uri 'https://github.com/autovfx/Tempest/archive/refs/heads/Limited-Version.zip' -OutFile "$env:TEMP\TMP.zip"; Expand-Archive -Path "$env:TEMP\TMP.zip" -DestinationPath "$env:TEMP\TMP" -Force; Set-Location "$env:TEMP\TMP\Tempest-Limited-Version"; powershell.exe -File .\TEMPEST%1.ps1

