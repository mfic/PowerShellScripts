$ErrorActionPreference = 0
$services = @(
    #"Service1",
    #"Svc*"
)


$services | ForEach-Object {

    # Loop over services within servers
    $service = Get-Service -Name $_
    # Check if service exists
    if (-not ($service.Length -gt 0)) {
        # Service does not exist
        Write-Host -ForegroundColor Yellow "Service $($_.Name) does not exist."
        return
    }
    # Check status for each service
    $service | Foreach-Object {
        if ($_.Status -eq "Running") {
            # Service is running
            Write-Host -ForegroundColor Green "Service $($_.Name) is already running."
            return
        }
        # Restart service if not running
        Write-Host -ForegroundColor Red "Restarting Service $($_.Name)."
        $_ | Stop-Service -Force -ErrorVariable errorStop
        $_ | Start-Service -ErrorVariable errorStart
        Write-Host -ForegroundColor Red "Service $($_.Name) restarted. `n Errors stopping: $errorStop `n Errors starting: $errorStart"
    }
}