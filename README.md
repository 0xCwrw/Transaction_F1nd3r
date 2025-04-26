# Transaction Finder (Transaction_F1nd3r)

`Transaction_F1nd3r` is a tool I made to experiment with PowerShell scripting and interacts with the [URLScan](https://urlscan.io/) API.

PowerShell implementation of URLScan.io's API to identify HTTP transactions made by a given domain/URL.

It uses the [URLScan](https://urlscan.io/) API to:
1. Submit one or many domains to the 'scan' API.
2. Wait for the scan to be complete.
3. Return the HTTP transactions made for each entry.
4. Optionally, uses the `-TargetDns` flag to specify your target and only return results that match. (Match is based on PowerShell `-like` fuzzy match with `*` pre/appended to the target DNS parameter.)
5. If `-TargetDns` is NOT specified, then it writes a PowerShell transaction log to `$HOME\Desktop\Transaction_F1nd3r.txt`.

Additionally, there is a standalone `TF1nd3r.ps1` that you can execute to load the primary `Check-URL` cmdlet into your current PowerShell session. This allows for single or continued use without the need to run the script each time.

## Quick usage:

### Transaction_F1nd3r.ps1
```powershell
./Transaction_F1nd3r.ps1
# Go through prompts...
# 1st prompt, enter single or multi, commma separated domains.
# 2nd prompt, enter the target or bad domain.
# 3rd wait, for many domains this process can take a long time as you will need to wait for URLScan to complete the scan in the background.
```

### TF1nd3r.ps1

```powershell
# Load PS1 into session...
./TF1nd3r.ps1
# Use Check-URL cmdlet directly in PS session.
Check-URL -Url URL_TO_SCAN.com -TargetDns Domain_To_Find.com
```
