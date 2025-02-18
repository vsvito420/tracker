# Repository URL
$repoUrl = "https://github.com/vsvito420/tracker.git"
$projectDir = "tracker"

# Check if Git is installed
$gitVersion = git --version
if (-not $?) {
    Write-Host "Git is not installed. Please install Git from https://git-scm.com/" -ForegroundColor Red
    exit 1
}

Write-Host "Git version $gitVersion detected" -ForegroundColor Green

# Check if Node.js is installed
$nodeVersion = node --version
if (-not $?) {
    Write-Host "Node.js is not installed. Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

Write-Host "Node.js version $nodeVersion detected" -ForegroundColor Green

# Clone the repository
Write-Host "`nCloning repository from GitHub..." -ForegroundColor Yellow
if (Test-Path $projectDir) {
    Write-Host "Directory '$projectDir' already exists. Please remove it or choose a different location." -ForegroundColor Red
    exit 1
}

git clone $repoUrl
if (-not $?) {
    Write-Host "Failed to clone repository" -ForegroundColor Red
    exit 1
}

Write-Host "Repository cloned successfully" -ForegroundColor Green

# Change to the project directory
Set-Location $projectDir/project

# Install dependencies
Write-Host "`nInstalling dependencies..." -ForegroundColor Yellow
npm install

if (-not $?) {
    Write-Host "Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "Dependencies installed successfully" -ForegroundColor Green

# Build the project
Write-Host "`nBuilding project..." -ForegroundColor Yellow
npm run build

if (-not $?) {
    Write-Host "Failed to build project" -ForegroundColor Red
    exit 1
}

Write-Host "Project built successfully" -ForegroundColor Green

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "`nTo start using the project:" -ForegroundColor Yellow
Write-Host "1. cd $projectDir/project" -ForegroundColor White
Write-Host "2. Run one of the following commands:" -ForegroundColor White
Write-Host "   - Development mode: npm run dev" -ForegroundColor White
Write-Host "   - Production preview: npm run preview" -ForegroundColor White
