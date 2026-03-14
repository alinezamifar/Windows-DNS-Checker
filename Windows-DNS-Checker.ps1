$Host.UI.RawUI.WindowTitle = "Bia2Host DNS Checker"
$ErrorActionPreference = "SilentlyContinue"

$Domain = "maryamsoft.com"
$DnsServers = @(
    "1.0.0.1",
    "1.1.1.1",
    "2.185.239.133",
    "2.185.239.134",
    "2.185.239.135",
    "2.185.239.136",
    "2.185.239.137",
    "2.185.239.138",
    "2.185.239.139",
    "2.188.21.130",
    "2.188.21.131",
    "2.188.21.132",
    "2.189.44.44",
    "5.145.112.39",
    "8.8.4.4",
    "8.8.8.8",
    "9.9.9.9",
    "10.202.10.10",
    "10.202.10.102",
    "10.202.10.202",
    "31.24.200.4",
    "31.24.234.37",
    "46.224.1.42",
    "78.157.42.100",
    "78.157.42.101",
    "80.191.209.105",
    "81.91.144.116",
    "85.15.1.14",
    "85.15.1.15",
    "85.185.85.6",
    "149.112.112.112",
    "178.22.122.100",
    "185.20.163.2",
    "185.20.163.4",
    "185.51.200.2",
    "185.51.200.3",
    "185.51.200.4",
    "185.53.143.3",
    "185.55.226.26",
    "185.161.112.38",
    "193.151.128.100",
    "193.151.128.200",
    "193.189.122.83",
    "193.189.123.2",
    "194.36.174.1",
    "194.60.210.66",
    "194.225.70.83",
    "194.225.152.10",
    "213.176.123.5",
    "217.218.127.127",
    "217.218.155.155",
    "217.219.72.194",
    "217.219.132.88"
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
Write-Host "Total DNS Servers: $($DnsServers.Count)" -ForegroundColor White
Write-Host ""

$results = @()
$total = $DnsServers.Count
$index = 0

foreach ($dns in $DnsServers) {
    $index++
    $percent = [int](($index / $total) * 100)

    Write-Progress -Activity "Please wait... DNS scan in progress" `
                   -Status "Checking $index / $total : $dns" `
                   -PercentComplete $percent

    try {
        $records = Resolve-DnsName -Name $Domain -Server $dns -Type A -DnsOnly -QuickTimeout -ErrorAction Stop

        $ips = @(
            $records |
            Where-Object { $_.Type -eq "A" -and $_.IPAddress } |
            Select-Object -ExpandProperty IPAddress -Unique
        )

        if ($ips.Count -gt 0) {
            $results += [PSCustomObject]@{
                DNS    = $dns
                Status = "OK"
                IPs    = ($ips -join ", ")
            }
        }
        else {
            $results += [PSCustomObject]@{
                DNS    = $dns
                Status = "FAIL"
                IPs    = "-"
            }
        }
    }
    catch {
        $results += [PSCustomObject]@{
            DNS    = $dns
            Status = "FAIL"
            IPs    = "-"
        }
    }
}

Write-Progress -Activity "Please wait... DNS scan in progress" -Completed

$ok = @($results | Where-Object { $_.Status -eq "OK" } | Sort-Object DNS)
$fail = @($results | Where-Object { $_.Status -eq "FAIL" } | Sort-Object DNS)

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
Write-Host "Total DNS Servers: $($DnsServers.Count)" -ForegroundColor White
Write-Host ""

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

$okList = ($ok | ForEach-Object { $_.DNS }) -join " "
Write-Host "Working DNS List:" -ForegroundColor Cyan
Write-Host $okList -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"