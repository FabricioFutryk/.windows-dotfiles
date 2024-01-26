$githubRepository = "https://github.com/belseir/.windows-dotfiles/archive/main.zip"

Invoke-WebRequest `
  -Uri $githubRepository `
  -OutFile "$HOME\Downloads\windows-dotfiles.zip"

Expand-Archive `
  -Path "$HOME\Downloads\windows-dotfiles.zip" `
  -DestinationPath "$HOME" `
  -Force

Rename-Item `
  -NewName ".windows-dotfiles" `
  -Path "$HOME\.windows-dotfiles-main" `
  -Force

Set-Location "$HOME\.windows-dotfiles\"

Invoke-Expression ".\install.ps1"