# push-to-github.ps1
# Creates the "Written" repository on GitHub and pushes this folder to it.
#
# Run it from this folder in PowerShell:
#     cd "$HOME\OneDrive\Documents\UPWORK\2026\Written\Website"
#     powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1
#
# Notes:
#   - Finds git and gh even when they are not on PATH yet.
#   - Native tools like gh write ordinary status messages to stderr, so this
#     script checks exit codes rather than treating stderr as fatal.

# Deliberately NOT 'Stop': with 'Stop', any stderr output from git or gh is
# promoted to a terminating error, which kills the script on messages that
# are not failures at all.
$ErrorActionPreference = 'Continue'

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

function Fail([string]$Message) {
    Write-Host ''
    Write-Host "  $Message" -ForegroundColor Red
    Write-Host ''
    exit 1
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
    Write-Host '  Install it with:  winget install --id Git.Git -e' -ForegroundColor Yellow
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
    Write-Host '  The GitHub CLI (gh) could not be found.' -ForegroundColor Red
    Write-Host '  Install it with:  winget install --id GitHub.cli -e' -ForegroundColor Yellow
    exit 1
}
Write-Host "  gh:  $Gh" -ForegroundColor DarkGray
Write-Host ''

# --- 3. line-ending hygiene --------------------------------------------------
if (-not (Test-Path '.gitattributes')) {
    @(
        '* text=auto',
        '',
        '*.png  binary',
        '*.jpg  binary',
        '*.jpeg binary',
        '*.pdf  binary',
        '*.zip  binary'
    ) | Set-Content -Path '.gitattributes' -Encoding ASCII
    Write-Host '  Added .gitattributes.' -ForegroundColor DarkGray
}

# --- 4. initialise the repository --------------------------------------------
if (Test-Path '.git') {
    Write-Host '  Repository already initialised.' -ForegroundColor DarkGray
} else {
    Write-Host '  Initialising repository...' -ForegroundColor DarkGray
    & $Git init -b main *> $null
    if ($LASTEXITCODE -ne 0) { Fail 'Could not initialise the repository.' }
}

& $Git add -A *> $null

$pending = & $Git status --porcelain
if ($pending) {
    & $Git commit -m 'Written landing page: initial commit' *> $null
    if ($LASTEXITCODE -ne 0) { Fail 'Commit failed.' }
    Write-Host '  Committed.' -ForegroundColor DarkGray
} else {
    Write-Host '  Nothing new to commit.' -ForegroundColor DarkGray
}

# --- 5. make sure we are signed in -------------------------------------------
& $Gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host '  Signing in to GitHub - follow the prompts below.' -ForegroundColor Yellow
    Write-Host '  Choose: GitHub.com  ->  HTTPS  ->  authenticate with a browser.' -ForegroundColor DarkGray
    Write-Host ''
    & $Gh auth login
    if ($LASTEXITCODE -ne 0) { Fail 'Sign-in did not complete. Run the script again once you are signed in.' }
}

$account = (& $Gh api user --jq .login)
if ($LASTEXITCODE -ne 0 -or -not $account) { Fail 'Could not read your GitHub account.' }
$account = $account.Trim()
Write-Host "  Signed in as $account." -ForegroundColor DarkGray

# --- 6. does the repository already exist? -----------------------------------
# A "could not resolve to a Repository" message here is the normal answer for
# a repo that does not exist yet - so only the exit code is consulted.
& $Gh repo view "$account/$RepoName" *> $null
$repoExists = ($LASTEXITCODE -eq 0)

# --- 7. create and push ------------------------------------------------------
if ($repoExists) {
    Write-Host "  Repository '$RepoName' already exists - pushing to it." -ForegroundColor DarkGray

    & $Git remote remove origin *> $null
    & $Git remote add origin "https://github.com/$account/$RepoName.git"
    if ($LASTEXITCODE -ne 0) { Fail 'Could not set the origin remote.' }

    & $Git push -u origin main
    if ($LASTEXITCODE -ne 0) { Fail 'Push failed. See the message above.' }
}
else {
    Write-Host "  Creating '$RepoName' on GitHub ($Visibility)..." -ForegroundColor DarkGray

    & $Gh repo create $RepoName "--$Visibility" --source . --remote origin --push
    if ($LASTEXITCODE -ne 0) { Fail 'Could not create the repository. See the message above.' }
}

Write-Host ''
Write-Host "  Done: https://github.com/$account/$RepoName" -ForegroundColor Green
Write-Host ''
