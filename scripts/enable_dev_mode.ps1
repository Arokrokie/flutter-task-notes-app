<#
  enable_dev_mode.ps1
  Usage: Run this script from an elevated PowerShell (Run as Administrator).
  It will create the registry key and set AllowDevelopmentWithoutDevLicense = 1
  to enable Developer Mode which permits non-admin symlink creation required
  by Flutter when building with plugins on Windows.

  IMPORTANT: Running scripts that edit HKLM requires Administrator privileges.
  To run:
    1. Open Start -> Windows PowerShell, right-click -> Run as Administrator
    2. cd to this project folder
    3. .\scripts\enable_dev_mode.ps1

#>

Write-Host "Checking Developer Mode registry key..."

$path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
if (-not (Test-Path $path)) {
    Write-Host "Registry key not found. Creating key: $path"
    New-Item -Path $path -Force | Out-Null
}
else {
    Write-Host "Registry key exists: $path"
}

Write-Host "Setting AllowDevelopmentWithoutDevLicense = 1"
Set-ItemProperty -Path $path -Name 'AllowDevelopmentWithoutDevLicense' -Value 1 -Type DWord -Force

Write-Host "Developer Mode should be enabled. You may need to sign out/sign in for changes to fully apply." -ForegroundColor Green
Write-Host "You can also open the Settings page with: start ms-settings:developers"
