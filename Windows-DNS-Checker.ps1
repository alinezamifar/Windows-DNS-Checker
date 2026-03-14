$Host.UI.RawUI.WindowTitle = "Bia2Host DNS Checker"
$ErrorActionPreference = "SilentlyContinue"

$Domain = "google.com"
$TimeoutSeconds = 4

$DnsServers = @(
    "85.15.1.14",
    "85.15.1.15",
    "217.218.155.155",
    "217.218.127.127",
    "2.188.21.130",
    "2.188.21.131",
    "2.188.21.132",
    "217.219.72.194",
    "2.185.239.133",
    "2.185.239.134",
    "2.185.239.135",
    "2.185.239.136",
    "2.185.239.137",
    "2.185.239.138",
    "2.185.239.139",
    "178.22.122.100",
    "185.51.200.2",
    "185.51.200.3",
    "193.151.128.100",
    "193.151.128.200",
    "10.202.10.202",
    "10.202.10.102",
    "81.91.144.116",
    "185.51.200.4",
    "193.189.123.2",
    "193.189.122.83",
    "194.225.70.83"
)

Clear-Host

Write-Host ""
Write-Host "BBBBBB   III   AAAAA   22222   H   H   OOO    SSSS   TTTTT" -ForegroundColor Cyan
Write-Host "B     B  III  A     A 2     2  H   H  O   O  S         T" -ForegroundColor Cyan
Write-Host "BBBBBB   III  AAAAAAA       2  HHHHH  O   O   SSS      T" -ForegroundColor Cyan
Write-Host "B     B  III  A     A     22   H   H  O   O      S     T" -ForegroundColor Cyan
Write-Host "BBBBBB   III  A     A   22222  H   H   OOO   SSSS      T" -ForegroundColor Cyan
Write-Host ""
Write-Host "Developed by Ali Nezamifar | Powered by Bia2Host.Com" -ForegroundColor Yellow
Write-Host "------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Target Domain: $Domain" -ForegroundColor White
Write-Host ""

$jobs = @()
foreach ($dns in $DnsServers) {
    $jobs += Start-Job -ArgumentList $dns, $Domain -ScriptBlock {
        param($DnsServer, $DomainName)

        try {
            $records = Resolve-DnsName -Name $DomainName -Server $DnsServer -Type A -DnsOnly -ErrorAction Stop
            $ips = @(
                $records |
                Where-Object { $_.Type -eq "A" -and $_.IPAddress } |
                Select-Object -ExpandProperty IPAddress -Unique
            )

            if ($ips.Count -gt 0) {
                [PSCustomObject]@{
                    DNS    = $DnsServer
                    Status = "OK"
                    IPs    = ($ips -join ", ")
                }
            }
            else {
                [PSCustomObject]@{
                    DNS    = $DnsServer
                    Status = "FAIL"
                    IPs    = "-"
                }
            }
        }
        catch {
            [PSCustomObject]@{
                DNS    = $DnsServer
                Status = "FAIL"
                IPs    = "-"
            }
        }
    }
}

$results = @()

foreach ($job in $jobs) {
    $done = Wait-Job -Job $job -Timeout $TimeoutSeconds

    if ($done) {
        $results += Receive-Job -Job $job
    }
    else {
        $dns = $job.ChildJobs[0].Command | Out-String
        Stop-Job -Job $job | Out-Null

        $results += [PSCustomObject]@{
            DNS    = "TIMEOUT"
            Status = "FAIL"
            IPs    = "-"
        }
    }

    Remove-Job -Job $job -Force | Out-Null
}

$final = @()
foreach ($dns in $DnsServers) {
    $item = $results | Where-Object { $_.DNS -eq $dns } | Select-Object -First 1
    if ($item) {
        $final += $item
    }
    else {
        $final += [PSCustomObject]@{
            DNS    = $dns
            Status = "FAIL"
            IPs    = "-"
        }
    }
}

$ok = @($final | Where-Object { $_.Status -eq "OK" } | Sort-Object DNS)
$fail = @($final | Where-Object { $_.Status -eq "FAIL" } | Sort-Object DNS)

Write-Host "========================= OK =========================" -ForegroundColor Green
if ($ok.Count -gt 0) {
    foreach ($item in $ok) {
        Write-Host ("[OK]   {0,-16} -> {1}" -f $item.DNS, $item.IPs) -ForegroundColor Green
    }
}
else {
    Write-Host "No OK DNS found." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "======================== FAIL ========================" -ForegroundColor Red
if ($fail.Count -gt 0) {
    foreach ($item in $fail) {
        Write-Host ("[FAIL] {0}" -f $item.DNS) -ForegroundColor Red
    }
}
else {
    Write-Host "No FAIL DNS found." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host ("Total: {0}   OK: {1}   FAIL: {2}" -f $DnsServers.Count, $ok.Count, $fail.Count) -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"