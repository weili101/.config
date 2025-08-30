<#
Quick Windows Setup Script (Customized)
Run as Administrator (right-click PowerShell → Run as Admin).
Save as setup.ps1 and execute: powershell -ExecutionPolicy Bypass -File .\setup.ps1
#>

# --- 1. Basic System Config ---
Write-Host "Configuring system..."
#Rename-Computer -NewName "MyLaptop" -Force -Restart:$false
Set-TimeZone -Name "Eastern Standard Time"

# Optional: Disable sleep on AC power
powercfg -change -standby-timeout-ac 0
powercfg -change -monitor-timeout-ac 15

# --- 2. Install Package Manager (Winget comes with Win 11/Win 10 21H2+) ---
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget not found. Please update Windows App Installer from Microsoft Store."
}

# --- 3. Install Essential Applications ---
$apps = @(
    "Google.Chrome",
    "Microsoft.VisualStudioCode",
    "7zip.7zip",
    "Zoom.Zoom",
    "Tencent.WeChat",
    "SumatraPDF.SumatraPDF",    # Sumatra PDF
    "DigitalScholar.Zotero",    # Zotero
    "Nutstore.Nutstore",        # Nutstore (网盘)
    "Apple.iCloud",             # iCloud
    "Obsidian.Obsidian"         # Obsidian
)

foreach ($app in $apps) {
    Write-Host "Installing $app..."
    winget install --id $app -e --accept-source-agreements --accept-package-agreements
}

# --- 4. Windows Update ---
Write-Host "Installing updates..."
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
Import-Module PSWindowsUpdate
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

# --- 5. Customization ---
# Example: Create workspace folders
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Projects"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Tools"

# Example: Set PowerShell profile
$profileContent = @"
# Custom PowerShell Profile
Import-Module oh-my-posh
Set-PoshPrompt -Theme paradox
"@
New-Item -ItemType File -Force -Path $PROFILE
Set-Content -Path $PROFILE -Value $profileContent

Write-Host "Setup complete. Please restart your computer."
