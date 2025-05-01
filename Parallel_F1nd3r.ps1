<#
    Author: Cwrw
    Description: PowerShell implementation of URLScan.io's API to identify HTTP transactions made by a given domain/URL.
    Date: 23 April 2025
#>

function Check-URL {
    param(
        [string]$Url,
        [string]$TargetDns
    )
    # Request body and authentication headers:
    $api = "... PUT API KEY HERE BOZO ..."
    if ($api -eq "... PUT API KEY HERE BOZO ..."){Write-Host -f Red "Please enter valid API key...`nC'mon you're better than this."; exit}
    $headers = @{
        "Content-Type" = "application/json"
        "API-Key" = $api
    }
    $body = @{
        url = "$Url"
        visibility = "public"
    } | ConvertTo-Json

    # Submit the scan to URLScan.io.
    Write-Host -f Magenta "`nChecking HTTP transactions for $Url"
    $scan_results = Invoke-RestMethod -Uri "https://urlscan.io/api/v1/scan/" -Headers $headers -Body $body -Method Post
    $uid = $scan_results.uuid

    # Sleep to allow scan to process on URLScan backend and check every 3 seconds.
    Start-Sleep -Seconds 10
    $res_check = Invoke-WebRequest "https://urlscan.io/api/v1/result/$uid/" -ErrorAction SilentlyContinue -SkipHeaderValidation
    if ($res_check.StatusCode -eq 200) { } else 
    {
        $attempts = 0
        do {
            Write-Host -f Yellow "Scan is not ready yet... Sleeping for five seconds."
            Start-Sleep -Seconds 5
            $res_check = Invoke-WebRequest "https://urlscan.io/api/v1/result/$uid/" -ErrorAction SilentlyContinue -SkipHeaderValidation
            $attempts++
        } until (( $res_check.StatusCode -eq 200 ) -or ($attempts -ge 5 ))
    }

    # Get results from successful scan:
    Write-Host -f Green "[+] $Url scan complete"
    $get_results = Invoke-RestMethod -Uri "https://urlscan.io/api/v1/result/$uid/" -ContentType application/json -Headers @{Authorization="API-KEY: $api"} -SkipHeaderValidation
    
    # Put the transactions list into the transactions variable.
    $transactions = $get_results.lists.urls

    # Check if TargetDns is present, null was throwing some bs so go for length check instead:
    if ($TargetDns.Length -ge 3 -and $transactions -like "*$TargetDns*"){
        Write-Host -f Green "[+] Target DNS transaction found in $Url."
        Write-Host -f Green "--------------- MATCHING TRANSACTIONS --------------" 
        $transactions -like "*$TargetDns*"
        Write-Host -f Green "----------------------------------------------------"
        return
    } else {
        Write-Host -f Yellow "[-] No target domain found in $Url."
        Write-Output $transactions
    }
}
$Check=${function:Check-URL}.ToString()
# Get input from user

$input_domains = Read-Host "Please enter the domains you wish to scan (comma separated)"
$splitDomains = $input_domains -split ',' | ForEach-Object -Process { $_.Trim() }

$TargetDns = Read-Host "Please enter the target domain you are looking for (the DNS request)"
$TargetDns = $TargetDns.Trim()

# Start transcript logging and cal
try {
    Stop-Transcript
} catch {
    Start-Transcript -Force -Path "$HOME\Desktop\Transaction_F1nd3r.txt"
}

# Start async job.
$splitDomains | ForEach-Object -Parallel {
    ${function:Check-URL} = $using:Check
    try {
        Check-URL -Url $_ -TargetDns $using:TargetDns
    } catch {
        Write-Host -f Red "[-] Please supply valid domains/URLs to scan."
    }

} -ThrottleLimit 10 

Stop-Transcript