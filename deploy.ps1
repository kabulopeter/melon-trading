# Deploy Script for Fly.io
# Usage: .\deploy.ps1

Write-Host ">>> Starting Deployment to Fly.io" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if flyctl is installed
if (-not (Get-Command flyctl -ErrorAction SilentlyContinue)) {
    # Try looking in default install location
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $flyPath = "$env:USERPROFILE\.fly\bin"
    if (Test-Path "$flyPath\flyctl.exe") {
        $env:Path += ";$flyPath"
    }
}

if (-not (Get-Command flyctl -ErrorAction SilentlyContinue)) {
    Write-Host "X Flyctl is not installed." -ForegroundColor Red
    Write-Host "Installing Flyctl..." -ForegroundColor Yellow
    iwr https://fly.io/install.ps1 -useb | iex
    
    # Try to add to path immediately for this session
    $flyPath = "$env:USERPROFILE\.fly\bin"
    if (Test-Path "$flyPath\flyctl.exe") {
        $env:Path += ";$flyPath"
    }
    else {
        Write-Host "Please restart PowerShell to use flyctl." -ForegroundColor Red
        exit
    }
}

# Check login
try {
    flyctl auth whoami | Out-Null
    Write-Host "V Connected to Fly.io" -ForegroundColor Green
}
catch {
    Write-Host "> Logging in to Fly.io..." -ForegroundColor Yellow
    flyctl auth login
}

# Check app status
try {
    flyctl status | Out-Null
    Write-Host "V App already exists" -ForegroundColor Green
}
catch {
    Write-Host "> Creating new app..." -ForegroundColor Yellow
    flyctl launch --no-deploy
    
    Write-Host "> Creating PostgreSQL database..." -ForegroundColor Yellow
    flyctl postgres create --name melon-trading-db --region cdg
    
    Write-Host "> Attaching database..." -ForegroundColor Yellow
    flyctl postgres attach melon-trading-db
    
    Write-Host "> Configuring secrets..." -ForegroundColor Yellow
    $secretKey = Read-Host "Enter your Django SECRET_KEY"
    flyctl secrets set SECRET_KEY="$secretKey"
    flyctl secrets set DEBUG="False"
    flyctl secrets set ALLOWED_HOSTS="melon-trading.fly.dev,*.fly.dev"
}

# Deploy
Write-Host ""
Write-Host "> Deploying..." -ForegroundColor Yellow
flyctl deploy

Write-Host ""
Write-Host "V Deployment Finished!" -ForegroundColor Green
Write-Host "URL: https://melon-trading.fly.dev" -ForegroundColor Cyan
Write-Host "Dashboard: https://fly.io/dashboard/pierre-kabulo" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  flyctl logs          - View logs"
Write-Host "  flyctl ssh console   - SSH into container"
Write-Host "  flyctl status        - View status"
