<#
.SYNOPSIS
    Assesses the completion of the Git collaboration challenge in a Skillable lab environment.
.DESCRIPTION
    This script navigates into the 'github-collaboration-project' repository and runs a series
    of checks to verify that all tasks from the challenge have been completed successfully.
    It checks for the existence of branches, files, tags, and specific log entries.
.OUTPUTS
    A PSCustomObject with two properties:
    - result: [boolean] $true if all checks pass, otherwise $false.
    - info:   [string] "All checks passed!" or a semicolon-separated list of failed checks.
#>

# --- SCRIPT CONFIGURATION ---
$repoPath = Join-Path $PSScriptRoot "github-collaboration-project"
$failedChecks = [System.Collections.Generic.List[string]]::new()

# --- HELPER FUNCTIONS ---
function Write-Check {
    param(
        [string]$Message
    )
    Write-Host "🔎 Checking: $Message"
}

# --- MAIN SCRIPT ---
Write-Host "--- Starting Git Collaboration Lab Assessment ---" -ForegroundColor Yellow

# Check 1: Is the repository directory present?
if (-not (Test-Path -Path $repoPath -PathType Container)) {
    Write-Host "❌ FATAL: Repository directory not found at '$repoPath'." -ForegroundColor Red
    $failedChecks.Add("Repository directory 'github-collaboration-project' does not exist.")
} else {
    # Navigate into the repository for all subsequent commands
    Set-Location -Path $repoPath

    # --- Task 1: Setting Up Remote Repository Connection ---
    Write-Check "Task 1: Repository Setup"
    if (-not (Test-Path -Path "remote-setup-log.txt")) { $failedChecks.Add("T1: 'remote-setup-log.txt' is missing.") }
    if (-not (git remote -v | Select-String "origin")) { $failedChecks.Add("T1: Git remote 'origin' is not configured.") }
    if (-not (Test-Path -Path ".gitignore")) { $failedChecks.Add("T1: '.gitignore' is missing.") }
    if (-not (Test-Path -Path "README.md")) { $failedChecks.Add("T1: 'README.md' is missing.") }

    # --- Task 2: Collaborative Branching Workflow ---
    Write-Check "Task 2: Branching Workflow"
    git checkout develop --quiet
    if (-not (git branch --list "develop")) { $failedChecks.Add("T2: 'develop' branch does not exist.") }
    if (-not (git ls-remote --heads origin "feature/data-processing" | Select-String "feature/data-processing")) { $failedChecks.Add("T2: 'feature/data-processing' branch was not pushed to remote.") }
    if (-not (Test-Path -Path "auth.py")) { $failedChecks.Add("T2: 'auth.py' is missing from develop branch.") }
    if (-not (Test-Path -Path "login.html")) { $failedChecks.Add("T2: 'login.html' is missing from develop branch.") }
    if (-not (Test-Path -Path "branching-strategy.txt")) { $failedChecks.Add("T2: 'branching-strategy.txt' is missing.") }


    # --- Task 3: Handling Merge Conflicts ---
    Write-Check "Task 3: Merge Conflict Resolution"
    if (-not (Test-Path -Path "config.py")) {
        $failedChecks.Add("T3: 'config.py' is missing.")
    } else {
        $configContent = Get-Content -Path "config.py" -Raw
        if (-not ($configContent -match "API_KEY" -and $configContent -match "DATABASE_URL")) { $failedChecks.Add("T3: 'config.py' was not merged correctly.") }
    }
    if (-not (git log -1 --pretty=%B | Select-String "Resolve merge conflict")) { $failedChecks.Add("T3: Merge conflict resolution commit not found.") }
    if (git branch --list "feature/config-updates") { $failedChecks.Add("T3: 'feature/config-updates' branch was not deleted locally.") }
    if (git ls-remote --heads origin "feature/config-updates" | Select-String "feature/config-updates") { $failedChecks.Add("T3: 'feature/config-updates' branch was not deleted from remote.") }
    if (-not (Test-Path -Path "conflict-resolution-log.txt")) { $failedChecks.Add("T3: 'conflict-resolution-log.txt' is missing.") }


    # --- Task 4: Pull Requests and Code Review Simulation ---
    Write-Check "Task 4: Pull Request Simulation"
    if (-not (Test-Path -Path "docs/API.md")) { $failedChecks.Add("T4: 'docs/API.md' is missing.") }
    if (-not (Test-Path -Path "docs/CONTRIBUTING.md")) { $failedChecks.Add("T4: 'docs/CONTRIBUTING.md' is missing.") }
    if (-not (Test-Path -Path "pull-request-description.txt")) { $failedChecks.Add("T4: 'pull-request-description.txt' is missing.") }
    if (-not (Test-Path -Path "pr-workflow-guide.txt")) { $failedChecks.Add("T4: 'pr-workflow-guide.txt' is missing.") }

    # --- Task 5: Advanced Git Collaboration Techniques ---
    Write-Check "Task 5: Advanced Techniques"
    $tags = git tag
    if (-not ($tags -contains "v1.0.0")) { $failedChecks.Add("T5: Tag 'v1.0.0' is missing.") }
    if (-not ($tags -contains "v1.0.1")) { $failedChecks.Add("T5: Tag 'v1.0.1' is missing.") }
    if (-not (git ls-remote --heads origin "release/v1.0.0" | Select-String "release/v1.0.0")) { $failedChecks.Add("T5: 'release/v1.0.0' branch was not pushed to remote.") }
    if (-not (Test-Path -Path "security.patch")) { $failedChecks.Add("T5: 'security.patch' hotfix file is missing.") }
    if (-not (Test-Path -Path "git-collaboration-guide.txt")) { $failedChecks.Add("T5: 'git-collaboration-guide.txt' is missing.") }
}

# --- Final Result ---
$allChecksPassed = $false
$infoMessage = "All checks passed!"

if ($failedChecks.Count -gt 0) {
    Write-Host "`n--- Assessment Complete: Some checks failed. ---" -ForegroundColor Red
    $infoMessage = $failedChecks -join "; "
} else {
    Write-Host "`n--- Assessment Complete: All checks passed! ---" -ForegroundColor Green
    $allChecksPassed = $true
}

# Return the custom object
return [PSCustomObject]@{
    result = $allChecksPassed
    info   = $infoMessage
}
