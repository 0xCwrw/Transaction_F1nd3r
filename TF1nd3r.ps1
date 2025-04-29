<#
    Author: Cwrw
    Description: This is the singular function extracted from the main Transaction_F1nd3r.ps1 script in this project. It allows you to run this script which loads the Check-URL function into your powershell session. Have fun :D.
    Date: 25 April 2025
#>

function Check-URL {
    param(
        [string]$Url,
        [string]$TargetDns
    )
    # Request body and authentication headers:
    $api = "... PUT API KEY HERE BOZO ..."
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
    try {
    $res_check = Invoke-WebRequest "https://urlscan.io/api/v1/result/$uid/" -ErrorAction SilentlyContinue -SkipHeaderValidation
    } catch { 
        while ($res_check.StatusCode -ne 200) {
        Write-Host -f Yellow "Scan is not ready yet... Sleeping for five seconds."
        Start-Sleep -Seconds 5
        $res_check = Invoke-WebRequest "https://urlscan.io/api/v1/result/$uid/" -ErrorAction SilentlyContinue -SkipHeaderValidation
        }
    }

    # Get results from successful scan:
    Write-Host -f Green "[+] $Url scan complete"
    $get_results = Invoke-RestMethod -Uri "https://urlscan.io/api/v1/result/$uid/" -ContentType application/json -Headers @{Authorization="API-KEY: $api"} -SkipHeaderValidation
    $transactions = $get_results.lists.urls

    # Check if TargetDns is present, null was throwing some bs so go for length check instead:
    if ($TargetDns.Length -ge 3 -and $transactions -like "*$TargetDns*"){
        Write-Host -f Green "[+] Target DNS transaction found in $Url.`n"
        $Url
        $transactions -like "*$TargetDns*"
        return
       } else {
        Write-Host -f Yellow "No target domain found, returning all values."
		Write-Host "--------------- $Url TRANSACTIONS--------------"
		$transactions   
		Write-Host "-----------------------------------------------"
    }
}
