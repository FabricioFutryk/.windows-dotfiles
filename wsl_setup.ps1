Unregister-ScheduledTask `
  -TaskName "WSL Setup" `
  -Confirm:$false

wsl

$wslUsername = wsl whoami

Copy-Item `
  -Path "$HOME\.windows-dotfiles\.gitconfig" `
  -Destination "\\wsl.localhost\Ubuntu\home\$wslUsername\.gitconfig"

wsl -e bash $(wsl wslpath -au "install.sh")