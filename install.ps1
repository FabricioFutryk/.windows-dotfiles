function DownloadAndExtract {
  param(
    [string]$Url,
    [string]$OutFile,
    [string]$DestinationPath
  )

  Invoke-WebRequest `
    -Uri $Url `
    -OutFile $OutFile

  Expand-Archive `
    -Path $OutFile `
    -DestinationPath $DestinationPath `
    -Force

  Remove-Item $OutFile -Force
}

function DownloadAndExecute {
  param(
    [string]$Url,
    [string]$OutFile,
    [string[]]$ArgumentList
  )

  Invoke-WebRequest `
    -Uri $Url `
    -OutFile $OutFile
  
  if($OutFile -match '\.cmd$') {
    Start-Process `
      -FilePath $OutFile `
      -ArgumentList $ArgumentList `
      -Wait
  } else {
    Invoke-Expression "$OutFile $ArgumentList"
  }

  Remove-Item $OutFile -Force
}

# .gitconfig values

$email = Read-Host "Enter your Git config email"
$name = Read-Host "Enter your Git config name"

$gitConfig = Get-Content ".gitconfig" -Raw

$gitConfig = $gitConfig -replace '<YOUR_EMAIL>', "$email"
$gitConfig= $gitConfig -replace '<YOUR_NAME>', "$name"

$gitConfig | Set-Content ".gitconfig"

##################################################################
## Windows Activation (massgravel/Microsoft-Activation-Scripts) ##
##################################################################

$hwidActivatorURL = 'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/HWID_Activation.cmd'

DownloadAndExecute `
  -Url $hwidActivatorURL `
  -OutFile "$env:TEMP\HWID_Activation.cmd" `
  -ArgumentList "/HWID"

##################################################
## Windows Debloat (LeDragoX/Win-Debloat-Tools) ##
##################################################

$debloaterUrl = "https://github.com/LeDragoX/Win-Debloat-Tools/archive/main.zip"

DownloadAndExtract `
  -Url $debloaterUrl `
  -OutFile "$env:TEMP\debloater.zip" `
  -DestinationPath "$env:TEMP"

Set-Location "$env:TEMP\Win-Debloat-Tools-main\"

Get-ChildItem `
  -Recurse *.ps*1 `
  | Unblock-File

Invoke-Expression "$env:TEMP\Win-Debloat-Tools-main\WinDebloatTools.ps1 CLI"

####################
## Terminal Setup ##
####################

New-Item -Force -ItemType SymbolicLink `
  -Path "$HOME\Documents\WindowsPowerShell" `
  -Target "$HOME\.windows-dotfiles\WindowsPowerShell" 

# Font Installation 

$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"

$fontsFile = "$env:TEMP\FiraCode.zip"
$fonts = "$env:TEMP\FiraCode"

DownloadAndExtract `
  -Url $fontUrl `
  -OutFile $fontsFile `
  -DestinationPath $fonts

# Gist (anthonyeden/0088b07de8951403a643a8485af2709b)

$destination = (New-Object -ComObject Shell.Application).Namespace(0x14)

Get-ChildItem -Path $fonts -Include 'FiraCodeNerdFontMono-*.ttf' -Recurse | ForEach-Object {
    If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {
    $destination.CopyHere("$fonts\$($_.Name)",0x10)
  }
}

Remove-Item `
  -Path $fonts `
  -Recurse `
  -Force

# Install Oh-My-Posh

Invoke-WebRequest `
  -Uri "https://ohmyposh.dev/install.ps1" `
  | Invoke-Expression

# Install Terminal Icons

Install-PackageProvider `
  -Name NuGet `
  -Confirm:$false `
  -Force

Install-Module `
  -Name Terminal-Icons `
  -Repository PSGallery `
  -Confirm:$false `
  -Force

###########################
## Software Installation ##
###########################

# Install Chocolatey

Invoke-WebRequest `
  -Uri "https://community.chocolatey.org/install.ps1" `
  | Invoke-Expression

Invoke-Expression "choco install brave discord steam vscode winget -y"
Invoke-Expression "winget install Microsoft.WindowsTerminal.Preview --accept-package-agreements --accept-source-agreements"

$installTraslucentTB = $Host.UI.PromptForChoice("TraslucentTB Installation", "Do you want to install TraslucentTB?", @("&Yes", "&No"), 0)

if($installTraslucentTB -eq 0) {
  Invoke-Expression "winget install TraslucentTB --accept-package-agreements --accept-source-agreements"
}

# Mouse Raw Acceleration 

$installRawAccel = $Host.UI.PromptForChoice("Raw Accel Installation", "Do you want to install Raw Accel?", @("&Yes", "&No"), 0)

if($installRawAccel -eq 0) {
  # Install Visual C++ 2015-2022 runtime
  Invoke-Expression "winget install Microsoft.VCRedist.2015+.x64 --accept-package-agreements --accept-source-agreements"

  # Install .NET Framework LTS runtime
  $dotnetUrl = "https://dot.net/v1/dotnet-install.ps1"

  DownloadAndExecute `
    -Url $dotnetUrl `
    -OutFile "$env:TEMP\dotnet-install.ps1" `
    -ArgumentList "-Channel LTS -Runtime dotnet"

  $rawaccelURL = "https://github.com/a1xd/rawaccel/releases/download/v1.6.1/RawAccel_v1.6.1.zip"

  DownloadAndExtract `
    -Url $rawaccelURL `
    -OutFile "$env:TEMP\RawAccel_v1.6.1.zip" `
    -DestinationPath "$env:ProgramFiles"

  Set-Location "$env:ProgramFiles\RawAccel\"

  Start-Process `
    -FilePath "$env:ProgramFiles\RawAccel\installer.exe" `
    -Wait
}

#* I'll skip Visual Studio Code extensions installation because they are synced to my github account (Might change opinion later)

##########################
## Setup Symbolic Links ##
##########################

New-Item -Force -ItemType SymbolicLink `
  -Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json" `
  -Target "$HOME\.windows-dotfiles\.terminal\settings.json"

New-Item -Force -ItemType SymbolicLink `
  -Path "$HOME\AppData\Roaming\Code\User\settings.json" `
  -Target "$HOME\.windows-dotfiles\.vscode\settings.json"

if($installRawAccel -eq 0) {
  New-Item -Force -ItemType SymbolicLink `
    -Path "$env:ProgramFiles\RawAccel\settings.json" `
    -Target "$HOME\.windows-dotfiles\.rawaccel\settings.json"
}

####################
## Task Scheduler ##
####################

# RawAccel

if($installRawAccel -eq 0) {
  $Action = New-ScheduledTaskAction `
    -Execute "$env:ProgramFiles\RawAccel\writer.exe" `
    -Argument "$env:ProgramFiles\RawAccel\settings.json"

  $Trigger = New-ScheduledTaskTrigger -AtLogOn

  Register-ScheduledTask `
    -Action $Action `
    -Trigger $Trigger `
    -TaskName 'RawAccel Startup'
}

#################################
## Windows Subsystem for Linux ##
#################################

#TODO: This part still needs testing

Set-Location "$HOME\.windows-dotfiles"

wsl --install

$wslUsername = wsl whoami

Copy-Item `
  -Path ".gitconfig" `
  -Destination "\\wsl.localhost\Ubuntu\home\$wslUsername\.gitconfig"

wsl -e bash $(wsl wslpath -au "install.sh")