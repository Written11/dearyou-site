# push-to-github.ps1
# Creates the "Written" repository on GitHub and pushes this folder to it.
#
# Run it from this folder in PowerShell:
#     cd "$HOME\OneDrive\Documents\UPWORK\2026\Written\Website"
#     powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1
#
# Finds git and gh even when they are not on PATH yet (which is normal right
# after installing them, until a new terminal window is opened).

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$RepoName   = 'Written'
$Visibility = 'private'   # change to 'public' if you'd rather it be public

# --- locate an executable, on PATH or in the usual install locations ---------
function Find-Exe {
    param(
        [string]   $Name,
        [string[]] $Candidates
    )

    $onPath = Get-Command $Name -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }

    foreach ($c in $Candidates) {
        $expanded = [Environment]::ExpandEnvironmentVariables($c)
        if (Test-Path $expanded) { return (Resolve-Path $expanded).Path }
    }

    return $null
}

Write-Host ''
Write-Host '  Written -> GitHub' -ForegroundColor Cyan
Write-Host '  -----------------' -ForegroundColor Cyan
Write-Host ''

# --- 1. locate git -----------------------------------------------------------
$Git = Find-Exe -Name 'git' -Candidates @(
    '%ProgramFiles%\Git\cmd\git.exe',
    '%ProgramFiles(x86)%\Git\cmd\git.exe',
    '%LOCALAPPDATA%\Programs\Git\cmd\git.exe',
    '%LOCALAPPDATA%\Microsoft\WinGet\Links\git.exe'
)

if (-not $Git) {
    Write-Host '  git could not be found.' -ForegroundColor Red
    Write-Host '  Install it with:' -ForegroundColor Yellow
    Write-Host '      winget install --id Git.Git -e' -ForegroundColor White
    Write-Host '  Then run this script again.' -ForegroundColor Yellow
    exit 1
}
Write-Host "  git: $Git" -ForegroundColor DarkGray

# --- 2. locate gh ------------------------------------------------------------
$Gh = Find-Exe -Name 'gh' -Candidates @(
    '%ProgramFiles%\GitHub CLI\gh.exe',
    '%ProgramFiles(x86)%\GitHub CLI\gh.exe',
    '%LOCALAPPDATA%\Programs\GitHub CLI\gh.exe',
    '%LOCALAPPDATA%\Microsoft\WinGet\Links\gh.exe',
    '%LOCALAPPDATA%\GitHubCLI\gh.exe'
)

if (-not $Gh) {
    Write-Host '  The GitHub CLI (gh) could not be found.' -ForegroundColor Yellow
    Write-Host '  Install it with:' -ForegroundColor Yellow
    Write-Host '      winget install --id GitHub.cli -e' -ForegroundColor White
    Write-Host ''
    Write-Host '  Or finish by hand:' -ForegroundColor Yellow
    Write-Host "      1. Create an empty repo named '$RepoName' at https://github.com/new" -ForegroundColor White
    Write-Host '         (do not add a README or .gitignore)' -ForegroundColor DarkGray
    Write-Host '      2. Then run:' -ForegroundColor White
    Write-Host "         git remote add origin https://github.com/<your-username>/$RepoName.git" -ForegroundColor White
    Write-Host '         git push -u origin main' -ForegroundColor White
    exit 1
}
Write-Host "  gh:  $Gh" -ForegroundColor DarkGray
Write-Host ''

# --- 3. initialise the repository --------------------------------------------
if (Test-Path '.git') {
    Write-Host '  Repository already initialised.' -ForegroundColor DarkGray
} else {
    Write-Host '  Initialising repository...' -ForegroundColor DarkGray
    & $Git init -b main | Out-Null
}

& $Git add -A

$pending = & $Git status --porcelain
if ($pending) {
    & $Git commit -m 'Written landing page: initial commit' | Out-Null
    Write-Host '  Committed.' -ForegroundColor DarkGray
} else {
    Write-Host '  Nothing new to commit.' -ForegroundColor DarkGray
}

# --- 4. sign in --------------------------------------------------------------
& $Gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host '  Signing in to GitHub - follow the prompts below.' -ForegroundColor Yellow
    Write-Host '  Choose: GitHub.com  ->  HTTPS  ->  authenticate with a browser.' -ForegroundColor DarkGray
    Write-Host ''
    & $Gh auth login
    if ($LASTEXITCODE -ne 0) {
        Write-Host '  Sign-in did not complete. Run the script again once you are signed in.' -ForegroundColor Red
        exit 1
    }
}

$account = (& $Gh api user --jq .login)
Write-Host ''
Write-Host "  Signed in as $account." -ForegroundColor DarkGray

# --- 5. create the remote and push -------------------------------------------
& $Gh repo view "$account/$RepoName" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Repository '$RepoName' already exists - pushing to it." -ForegroundColor DarkGray
    & $Git remote remove origin 2>$null | Out-Null
    & $Git remote add origin "https://github.com/$account/$RepoName.git"
    & $Git push -u origin main
} else {
    Write-Host "  Creating '$RepoName' on GitHub ($Visibility)..." -ForegroundColor DarkGray
    & $Gh repo create $RepoName "--$Visibility" --source . --remote origin --push
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host '  Push failed. See the message above.' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host "  Done: https://github.com/$account/$RepoName" -ForegroundColor Green
Write-Host ''
