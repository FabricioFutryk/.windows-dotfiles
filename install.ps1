Import-Module "$HOME\.windows-dotfiles\utils.ps1"

$dotfilesFolder = "$HOME\.windows-dotfiles"

$urls = @{
  hwidActivator = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/HWID_Activation.cmd"
  debloater = "https://github.com/LeDragoX/Win-Debloat-Tools/archive/main.zip"
  fonts = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
  ohMyPosh = "https://ohmyposh.dev/install.ps1"
  chocolatey = "https://community.chocolatey.org/install.ps1"
  dotnet = "https://dot.net/v1/dotnet-install.ps1"
  rawAccel = "https://github.com/a1xd/rawaccel/releases/download/v1.6.1/RawAccel_v1.6.1.zip"
}

$fontName = "FiraCodeNerdFontMono-*.ttf"

# .gitconfig values

$email = Read-Host "Enter your Git config email"
$name = Read-Host "Enter your Git config name"

$gitConfig = Get-Content ".gitconfig" -Raw

$gitConfig = $gitConfig `
  -replace '<YOUR_EMAIL>', "$email" `
  -replace '<YOUR_NAME>', "$name"

$gitConfig | Set-Content ".gitconfig"

##################################################################
## Windows Activation (massgravel/Microsoft-Activation-Scripts) ##
##################################################################

Download-And-Execute `
  -Url $urls.hwidActivator `
  -OutFile "$env:TEMP\HWID_Activation.cmd" `
  -ArgumentList "/HWID"

##################################################
## Windows Debloat (LeDragoX/Win-Debloat-Tools) ##
##################################################

Download-And-Extract `
  -Url $urls.debloater `
  -OutFile "$env:TEMP\debloater.zip" `
  -DestinationPath "$env:TEMP"

Set-Location "$env:TEMP\Win-Debloat-Tools-main\"

Get-ChildItem `
  -Recurse *.ps*1 `
  | Unblock-File

Invoke-Item ( 
  Start-Process powershell `
    "$env:TEMP\Win-Debloat-Tools-main\WinDebloatTools.ps1 CLI" `
    -Wait `
    -WindowStyle Minimized
)

Set-Location $dotfilesFolder

####################
## Terminal Setup ##
####################

New-Item -Force -ItemType SymbolicLink `
  -Path "$HOME\Documents\WindowsPowerShell" `
  -Target "$dotfilesFolder\WindowsPowerShell" 

# Font Installation 

$fontsFile = "$env:TEMP\FiraCode.zip"
$fonts = "$env:TEMP\FiraCode"

Download-And-Extract `
  -Url $urls.fonts `
  -OutFile $fontsFile `
  -DestinationPath $fonts

# Gist (anthonyeden/0088b07de8951403a643a8485af2709b)

$destination = (New-Object -ComObject Shell.Application).Namespace(0x14)

Get-ChildItem -Path $fonts -Include $fontName -Recurse | ForEach-Object {
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
  -Uri $urls.ohMyPosh `
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

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 

Invoke-WebRequest `
  -Uri $urls.chocolatey `
| Invoke-Expression

Invoke-Expression "choco install brave discord steam vscode winget -y"
Invoke-Expression "winget install Microsoft.WindowsTerminal.Preview --accept-package-agreements  --accept-source-agreements"

$installTraslucentTB = $Host.UI.PromptForChoice("TraslucentTB Installation", "Do you want to install TraslucentTB?", @("&Yes", "&No"), 0)

if($installTraslucentTB -eq 0) {
  Invoke-Expression "winget install TranslucentTB --accept-package-agreements --accept-source-agreements"
}

# Mouse Raw Acceleration 

$installRawAccel = $Host.UI.PromptForChoice("Raw Accel Installation", "Do you want to install Raw Accel?", @("&Yes", "&No"), 0)

if($installRawAccel -eq 0) {
  # Install Visual C++ 2015-2022 runtime
  Invoke-Expression "winget install Microsoft.VCRedist.2015+.x64 --accept-package-agreements --accept-source-agreements"

  # Install .NET Framework LTS runtime
  Download-And-Execute `
    -Url $urls.dotnet `
    -OutFile "$env:TEMP\dotnet-install.ps1" `
    -ArgumentList "-Channel LTS -Runtime dotnet"

  Download-And-Extract `
    -Url $urls.rawAccel `
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
  -Target "$dotfilesFolder\.terminal\settings.json"

New-Item -Force -ItemType SymbolicLink `
  -Path "$HOME\AppData\Roaming\Code\User\settings.json" `
  -Target "$dotfilesFolder\.vscode\settings.json"

if($installRawAccel -eq 0) {
  New-Item -Force -ItemType SymbolicLink `
    -Path "$env:ProgramFiles\RawAccel\settings.json" `
    -Target "$dotfilesFolder\.rawaccel\settings.json"
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
    -TaskName 'RawAccel Startup' `
    -Force
}

#################################
## Windows Subsystem for Linux ##
#################################

#TODO: This part still needs testing

Set-Location $dotfilesFolder

wsl --install --no-launch

$wslUsername = wsl whoami

Copy-Item `
  -Path "$dotfilesFolder\.gitconfig" `
  -Destination "\\wsl.localhost\Ubuntu\home\$wslUsername\.gitconfig"

wsl -e bash $(wsl wslpath -au "install.sh")