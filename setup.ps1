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
    "JanDeDobbeleer.OhMyPosh",
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

# --- 5. Customization ---
# Example: Create workspace folders
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Projects"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Tools"

# Example: Set PowerShell profile
$profileContent = @"
# Custom PowerShell Profile
oh-my-posh init pwsh | Invoke-Expression
#Import-Module oh-my-posh
oh-my-posh init pwsh --config ~/jandedobbeleer.omp.json | Invoke-Expression
#Set-PoshPrompt -Theme paradox
"@
oh-my-posh font install meslo
New-Item -ItemType File -Force -Path $PROFILE
Set-Content -Path $PROFILE -Value $profileContent

Write-Host "Setup complete. Please restart your computer."
