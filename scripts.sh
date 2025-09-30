# Git Fundamentals Assessment Script
# Requires: Git installed and accessible via PATH

$errors = @()

# --- Task 1: Repo Setup ---
$projectPath = Join-Path (Get-Location) "activity\git-fundamentals-project"

if (-not (Test-Path $projectPath)) {
    $errors += "Task 1.1: Project directory not found."
} else {
    Set-Location $projectPath

    # Check Git repo exists
    if (-not (Test-Path ".git")) {
        $errors += "Task 1.2: Git repository not initialized."
    }

    # Check config
    $username = git config user.name
    $email = git config user.email
    if ($username -ne "TestUser") { $errors += "Task 1.3: Git username not configured correctly." }
    if ($email -ne "testuser@example.com") { $errors += "Task 1.3: Git email not configured correctly." }

    # Check .gitignore
    if (-not (Test-Path ".gitignore")) { $errors += "Task 1.4: .gitignore file missing." }

    # Check README
    if (-not (Test-Path "README.md")) { $errors += "Task 1.5: README.md missing." }

    # Check git-setup-log.txt
    if (-not (Test-Path "git-setup-log.txt")) { $errors += "Task 1.8: git-setup-log.txt missing." }
}

# --- Task 2: Git States ---
foreach ($file in @("main.java", "utils.java", "config.json")) {
    if (-not (Test-Path $file)) { $errors += "Task 2.1: Missing file $file." }
}
if (-not (Test-Path "git-states-explanation.txt")) {
    $errors += "Task 2.10: git-states-explanation.txt missing."
}

# --- Task 3: Git History ---
$commitCount = (git rev-list --count HEAD)
if ($commitCount -lt 4) { $errors += "Task 3.1: Not enough commits (need at least 4)." }
if (-not (Test-Path "commit-history.txt")) { $errors += "Task 3.7: commit-history.txt missing." }
if (-not (Test-Path "git-log-analysis.txt")) { $errors += "Task 3.8: git-log-analysis.txt missing." }

# --- Task 4: Branching ---
$branches = git branch --format="%(refname:short)"
if ($branches -notmatch "feature-development") { $errors += "Task 4.1: feature-development branch missing." }
if ($branches -notmatch "bugfix") { $errors += "Task 4.6: bugfix branch missing." }
if (-not (Test-Path "branching-workflow.txt")) { $errors += "Task 4.11: branching-workflow.txt missing." }
if (-not (Test-Path "git-commands-summary.txt")) { $errors += "Task 4.12: git-commands-summary.txt missing." }

# --- Task 5: Best Practices ---
if ($branches -notmatch "development") { $errors += "Task 5.1: development branch missing." }
if (-not (Test-Path "docs")) { $errors += "Task 5.4: docs folder missing." }
if (-not (Test-Path "git-workflow-guide.txt")) { $errors += "Task 5.8: git-workflow-guide.txt missing." }

# --- Final Result ---
$result = [PSCustomObject]@{
    result = ($errors.Count -eq 0)
    info   = $(if ($errors.Count -eq 0) { "All tasks completed successfully." } else { ($errors -join "; ") })
}

# Output the object
$result
