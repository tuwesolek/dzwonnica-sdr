# Local network access

Dzwonnica SDR serves the frontend, API, and WebSockets from the same port. The
server binds to `0.0.0.0:9002`, and Docker publishes that port on every host
interface.

## Start the service

```bash
docker compose up -d --build
```

On older Docker installations use `docker-compose` instead of `docker compose`.

## Find the host address

On Windows PowerShell:

```powershell
Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } |
  Select-Object InterfaceAlias, IPAddress
```

Use the address of the Ethernet or Wi-Fi adapter, for example:

```text
http://192.168.1.50:9002
```

Do not use the container IP or the internal WSL virtual-adapter address from
another device.

## Windows firewall

The current network should use the Windows `Private` profile. Check it with
`Get-NetConnectionProfile`. If necessary, open an elevated PowerShell window
and change the profile (replace the interface name when using Ethernet):

```powershell
Set-NetConnectionProfile -InterfaceAlias "Wi-Fi" -NetworkCategory Private
```

Then, in the same elevated window, add a rule limited to the local subnet:

```powershell
New-NetFirewallRule -DisplayName "Dzwonnica SDR (TCP 9002)" `
  -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9002 `
  -Profile Private -RemoteAddress LocalSubnet
```

Do not expose port 9002 through the router unless public Internet access is
deliberately secured with authentication and TLS.

## Verify

On the host:

```bash
curl http://localhost:9002
docker compose ps
```

On a second device connected to the same LAN, open
`http://HOST_LAN_IP:9002`. WebSockets require no separate port: the frontend
uses the same browser hostname and automatically selects `ws://` or `wss://`.
