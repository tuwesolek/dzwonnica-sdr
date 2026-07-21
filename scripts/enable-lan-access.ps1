$ErrorActionPreference = "Stop"

Set-NetConnectionProfile -InterfaceAlias "Wi-Fi" -NetworkCategory Private

$ruleName = "Dzwonnica SDR (TCP 9002)"
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($existingRule) {
    Set-NetFirewallRule -DisplayName $ruleName -Enabled True -Direction Inbound -Action Allow -Profile Private
    Get-NetFirewallRule -DisplayName $ruleName | Get-NetFirewallPortFilter |
        Set-NetFirewallPortFilter -Protocol TCP -LocalPort 9002
    Get-NetFirewallRule -DisplayName $ruleName | Get-NetFirewallAddressFilter |
        Set-NetFirewallAddressFilter -RemoteAddress LocalSubnet
} else {
    New-NetFirewallRule -DisplayName $ruleName `
        -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9002 `
        -Profile Private -RemoteAddress LocalSubnet | Out-Null
}

Write-Host ""
Write-Host "Dzwonnica SDR: dostep LAN zostal wlaczony." -ForegroundColor Green
Write-Host "Adres: http://192.168.68.56:9002"
Start-Sleep -Seconds 5
