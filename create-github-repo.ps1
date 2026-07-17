# Create GitHub repo (run AFTER: gh auth login)
# Usage: powershell -ExecutionPolicy Bypass -File .\create-github-repo.ps1
# Optional:  -BinPath "C:\path\to\sysupgrade.bin"

param(
  [string]$RepoName = "rtwrt-aw1000-firmware",
  [string]$Visibility = "public",
  [string]$BinPath = ""
)

$ErrorActionPreference = "Continue"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

gh auth status
if ($LASTEXITCODE -ne 0) {
  Write-Host "Login first: gh auth login"
  exit 1
}

$user = (gh api user --jq .login).Trim()
Write-Host "Logged in as: $user" -ForegroundColor Cyan

Set-Location $PSScriptRoot

$ge = git config --global user.email 2>$null
$gn = git config --global user.name 2>$null
if (-not $ge) { git config --global user.email "rtwrt@$user.github" | Out-Null }
if (-not $gn) { git config --global user.name $user | Out-Null }

if (-not (Test-Path .git)) {
  git init -b main
  git add README.md .gitignore fw-offers.example.json create-github-repo.ps1
  git commit -m "Initial RTWRT firmware release repo"
}

# "repo not found" is normal — do not treat as fatal
$repoExists = $false
cmd /c "gh repo view $user/$RepoName 1>nul 2>nul"
if ($LASTEXITCODE -eq 0) { $repoExists = $true }

if (-not $repoExists) {
  Write-Host "Creating $Visibility repo $user/$RepoName ..." -ForegroundColor Green
  gh repo create $RepoName --$Visibility --description "RTWRT Arcadyan AW1000 firmware releases"
  if ($LASTEXITCODE -ne 0) {
    Write-Host "gh repo create failed" -ForegroundColor Red
    exit 1
  }
  git remote remove origin 2>$null
  git remote add origin "https://github.com/$user/$RepoName.git"
  git branch -M main
  git push -u origin main
  if ($LASTEXITCODE -ne 0) {
    Write-Host "git push failed" -ForegroundColor Red
    exit 1
  }
} else {
  Write-Host "Repo already exists. Pushing..." -ForegroundColor Yellow
  git remote remove origin 2>$null
  git remote add origin "https://github.com/$user/$RepoName.git"
  git branch -M main
  git push -u origin main
}

Write-Host ""
Write-Host "Repo: https://github.com/$user/$RepoName" -ForegroundColor Green
Write-Host ""
Write-Host "Next: create a Release and attach the .bin (do NOT git commit the bin)" -ForegroundColor Cyan

if ($BinPath -and (Test-Path $BinPath)) {
  $name = Split-Path $BinPath -Leaf
  Write-Host "Creating/updating release v3 with $name ..."
  cmd /c "gh release view v3 --repo $user/$RepoName 1>nul 2>nul"
  if ($LASTEXITCODE -eq 0) {
    gh release upload v3 $BinPath --repo "$user/$RepoName" --clobber
  } else {
    gh release create v3 $BinPath --repo "$user/$RepoName" --title "RTWRT Premium v3" --notes "Arcadyan AW1000 sysupgrade for RTWRT app"
  }
  Write-Host "Download URL:" -ForegroundColor Green
  Write-Host "https://github.com/$user/$RepoName/releases/download/v3/$name"
} else {
  Write-Host ""
  Write-Host "Create release in browser:"
  Write-Host "  https://github.com/$user/$RepoName/releases/new"
  Write-Host "  Tag: v3"
  Write-Host "  Attach: your sysupgrade.bin"
  Write-Host ""
  Write-Host "Or CLI:"
  Write-Host "  gh release create v3 `"C:\path\to\sysupgrade.bin`" --title `"RTWRT Premium v3`" --notes `"AW1000`""
}
