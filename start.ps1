# stop when an error occurs
$ErrorActionPreference = "Stop"

Write-Host "Starting infrastructure..."
docker compose up -d

Write-Host "Waiting for model initialization to complete..."

# start log streaming in the background
$logJob = Start-Job -ScriptBlock {
    docker compose logs -f ollama-init
}

# wait until the init container has finished
docker wait multi-user-ai-infrastructure-ollama-init-1 | Out-Null

# stop the log job
Stop-Job $logJob | Out-Null
Remove-Job $logJob | Out-Null

Write-Host ""
Write-Host "✔ Models successfully installed."
Write-Host "✔ OpenWebUI is ready at: http://localhost:8080"
