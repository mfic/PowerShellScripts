$ErrorActionPreference = 0

$evntLogName = "Check-Service"

$servers = @{
    #"Computer-Name-1" = @("Service1", "Service2")
    #"Computer-Name-2" = @("Service1", "Svc*")
}

# Create new Event Source if not exists
$logFileExists = [System.Diagnostics.EventLog]::Exists($evntLogName)
if (-not $logFileExists) {
    New-EventLog -LogName "Application" -Source $evntLogName
}

# Loop over servers
foreach ($server in $servers.GetEnumerator() ) {
    # Loop over services within servers
    foreach ($svc in $server.Value) {
        $service = Get-Service -ComputerName $server.Key -Name $svc
        # Check if service exists
        if (-not ($service.Length -gt 0)) {
            # Service does not exist
            Write-EventLog -LogName 'Application' -Source 'Check-Service' -EntryType 'Warning' -EventID 3 -Message "$($_.Name) on $($server.Key) does not exists."
            return
        }
        # Check status for each service
        $service | Foreach-Object {
            if ($_.Status -eq "Running") {
                # Service is running
                Write-EventLog -LogName 'Application' -Source 'Check-Service' -EntryType 'Information' -EventID 1 -Message "$($_.Name) on $($server.Key) already running."
                return
            }
            # Restart service if not running
            $_ | Stop-Service -Force -ErrorVariable errorStop
            $_ | Start-Service -ErrorVariable errorStart

            Write-EventLog -LogName 'Application' -Source 'Check-Service' -EntryType 'Warning' -EventID 2 -Message "$($_.Name) on $($server.Key) restarted. `n Errors stopping: $errorStop `n Errors starting: $errorStart"
        }
    }
}
