# Check if Node.js is installed
$nodeVersion = node --version
if (-not $?) {
    Write-Host "Node.js is not installed. Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

Write-Host "Node.js version $nodeVersion detected" -ForegroundColor Green

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install

if (-not $?) {
    Write-Host "Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "Dependencies installed successfully" -ForegroundColor Green

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow
npm run build

if (-not $?) {
    Write-Host "Failed to build project" -ForegroundColor Red
    exit 1
}

Write-Host "Project built successfully" -ForegroundColor Green

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "`nTo run the development server:" -ForegroundColor Yellow
Write-Host "npm run dev" -ForegroundColor White
Write-Host "`nTo preview the production build:" -ForegroundColor Yellow
Write-Host "npm run preview" -ForegroundColor White
