# Windows Dotfiles

> [!IMPORTANT] > **Windows 11** is required. A clean installation is recommended.

> [!WARNING]
> The scripts and configurations are under ongoing development, and some features may not be fully tested. Use with caution.

## Features

- **Windows HWID Activation**
- **Windows Debloating**
- **Terminal Customization**
- **Applications:**
  - Brave
  - Discord
  - Steam
  - Vs Code
  - Windows Terminal Preview
  - TraslucentTB (Optional)
  - Raw Accel (Optional)
- **Windows Subsystem for Linux (WSL):**
  - Distribution: Ubuntu
  - Packages: nodejs python3 git docker gh
  - Bun
  - Github SSH Configuration

## Installation

You can install these dotfiles using one of the following methods:

> [!IMPORTANT]
> After the debloating step, a restart will be requested. Press "No"; another restart will be requested to finish WSL installation. Input Y/Yes on that one to restart the computer.

### Method 1: Quick Setup

If you prefer a quick setup without manually downloading the repository, use the bootstrap script:

1. Run Bootstrap Script:

   Open a PowerShell or Windows Terminal as an administrator and execute the following command:

```ps1
Invoke-WebRequest https://raw.githubusercontent.com/belseir/.windows-dotfiles/main/bootstrap.ps1 | Invoke-Expression
```

> [!NOTE]
> The bootstrap script will automatically fetch the latest version from the GitHub repository.

### Method 2: Manual

1. Download Repository:

   Download and extract the repository to your Windows `$HOME` directory. Ensure that all files are located in `C:\Users\<YOUR_USERNAME>\.windows-dotfiles\`.

2. Installation Script:

   Open a PowerShell or Windows Terminal as an administrator in the directory where the files were extracted. Execute the following command:

```ps1
Invoke-Expression "$HOME\.windows-dotfiles\install.ps1"
```

## Credits

[Windows Activation Script (massgravel/Microsoft-Activation-Scripts)](https://github.com/massgravel/Microsoft-Activation-Scripts)

[Windows Debloat (LeDragoX/Win-Debloat-Tools)](https://github.com/LeDragoX/Win-Debloat-Tools)
