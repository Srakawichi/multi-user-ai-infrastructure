# Stoppe bei Fehlern
$ErrorActionPreference = "Stop"

Write-Host "Starting infrastructure..."
docker compose up -d

Write-Host "Waiting for model initialization to complete..."

# Logs im Hintergrund starten
$logJob = Start-Job -ScriptBlock {
    docker compose logs -f ollama-init
}

# Warten bis der Init-Container beendet ist
docker wait multi-user-ai-infrastructure-ollama-init-1 | Out-Null

# Log-Job stoppen
Stop-Job $logJob | Out-Null
Remove-Job $logJob | Out-Null

Write-Host ""
Write-Host "✔ Models successfully installed."
Write-Host "✔ OpenWebUI is ready at: http://localhost:8080"
