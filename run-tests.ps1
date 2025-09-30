# Simplified Verification Script (Version 1.1: Boolean fix)

# --- Script Parameters ---
param(
    [string]$ProjectPath = "$env:USERPROFILE\Desktop\activity\git-fundamentals-project"
)

# --- Script-Scoped list to collect failure messages ---
$script:failureMessages = [System.Collections.Generic.List[string]]::new()

# --- Helper Functions ---
function Check-Requirement {
    param(
        [Parameter(Mandatory=$true)]
        [bool]$Condition,
        [Parameter(Mandatory=$true)]
        [string]$FailureMessage
    )
    if (-not $Condition) {
        $script:failureMessages.Add($FailureMessage)
        return $false
    }
    return $true
}

function Test-FileNotEmpty {
    param([string]$FilePath)
    return (Test-Path $FilePath) -and ((Get-Item $FilePath).Length -gt 0)
}

# --- Main Script ---

# --- Pre-checks ---
if (-not (Test-Path $ProjectPath -PathType Container)) {
    return [PSCustomObject]@{ result = $false; info = "CRITICAL: Project directory not found at: $ProjectPath" }
}
if (-not (Test-Path (Join-Path $ProjectPath ".git"))) {
    return [PSCustomObject]@{ result = $false; info = "CRITICAL: Directory is not a Git repository." }
}

# --- Verification Logic ---
$AllChecksPassed = $true
$MainBranchName = if ($(git -C $ProjectPath branch --list main)) { "main" } else { "master" }

# Task 1
$task1_passed = $true
$task1_passed = (Check-Requirement (Test-Path (Join-Path $ProjectPath ".git") -PathType Container) "Task 1: Git repo not initialized.") -and $task1_passed
$task1_passed = (Check-Requirement ($(git -C $ProjectPath config user.name) -eq "TestUser") "Task 1: Git user.name is not 'TestUser'.") -and $task1_passed
$task1_passed = (Check-Requirement ($(git -C $ProjectPath config user.email) -eq "testuser@example.com") "Task 1: Git user.email is not 'testuser@example.com'.") -and $task1_passed
$gitignorePath = Join-Path $ProjectPath ".gitignore"
# This simply checks that the .gitignore file was created and is not empty.
$task1_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath ".gitignore")) "Task 1: .gitignore file is missing or empty.") -and $task1_passed
$task1_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "README.md")) "Task 1: README.md is missing or empty.") -and $task1_passed
$task1_passed = (Check-Requirement ((git -C $ProjectPath log).Length -gt 0) "Task 1: No commits found in repository.") -and $task1_passed
$task1_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-setup-log.txt")) "Task 1: 'git-setup-log.txt' is missing or empty.") -and $task1_passed
if (-not $task1_passed) { $AllChecksPassed = $false }

# Task 2
$task2_passed = $true
$filesInRepo = git -C $ProjectPath ls-tree -r HEAD --name-only
$task2_passed = (Check-Requirement ($filesInRepo -contains "main.java" -and $filesInRepo -contains "utils.java" -and $filesInRepo -contains "config.json") "Task 2: main.java, utils.java, or config.json have not been committed.") -and $task2_passed
$task2_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-states-explanation.txt")) "Task 2: 'git-states-explanation.txt' is missing or empty.") -and $task2_passed
if (-not $task2_passed) { $AllChecksPassed = $false }

# Task 3
$task3_passed = $true
$task3_passed = (Check-Requirement ((git -C $ProjectPath log --oneline).Count -ge 5) "Task 3: Fewer than 5 commits found.") -and $task3_passed
$task3_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "commit-history.txt")) "Task 3: 'commit-history.txt' is missing or empty.") -and $task3_passed
$task3_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-log-analysis.txt")) "Task 3: 'git-log-analysis.txt' is missing or empty.") -and $task3_passed
if (-not $task3_passed) { $AllChecksPassed = $false }

# Task 4
$task4_passed = $true
$branches = git -C $ProjectPath branch
$task4_passed = (Check-Requirement ([bool]($branches -match "feature-development")) "Task 4: Branch 'feature-development' was not found.") -and $task4_passed # <-- CORRECTED
$task4_passed = (Check-Requirement ([bool]($branches -match "bugfix")) "Task 4: Branch 'bugfix' was not found.") -and $task4_passed # <-- CORRECTED
$task4_passed = (Check-Requirement ((git -C $ProjectPath ls-tree -r "feature-development" --name-only) -contains "feature.java") "Task 4: 'feature.java' was not found on the 'feature-development' branch.") -and $task4_passed
# This robustly checks if the bugfix branch's history is part of the main branch's history.
$bugfixHead = git -C $ProjectPath rev-parse bugfix
$mergeBase = git -C $ProjectPath merge-base $MainBranchName bugfix
$task4_passed = (Check-Requirement ($bugfixHead -eq $mergeBase) "Task 4: The 'bugfix' branch has not been merged into '$MainBranchName'.") -and $task4_passed
$task4_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "branching-workflow.txt")) "Task 4: 'branching-workflow.txt' is missing or empty.") -and $task4_passed
$task4_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-commands-summary.txt")) "Task 4: 'git-commands-summary.txt' is missing or empty.") -and $task4_passed
if (-not $task4_passed) { $AllChecksPassed = $false }

# Task 5
$task5_passed = $true
$task5_passed = (Check-Requirement ([bool]($(git -C $ProjectPath branch) -match "development")) "Task 5: Branch 'development' was not found.") -and $task5_passed # <-- CORRECTED
$task5_passed = (Check-Requirement (Test-Path (Join-Path $ProjectPath "docs") -PathType Container) "Task 5: The 'docs' folder is missing.") -and $task5_passed
$task5_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-workflow-guide.txt")) "Task 5: 'git-workflow-guide.txt' is missing or empty.") -and $task5_passed
$task5_passed = (Check-Requirement ([string]::IsNullOrEmpty($(git -C $ProjectPath status --porcelain))) "Task 5: Repository has uncommitted changes.") -and $task5_passed
if (-not $task5_passed) { $AllChecksPassed = $false }

# --- Final Object Creation ---
$infoString = ""
if ($AllChecksPassed) {
    $infoString = "Congratulations! All checks passed."
} else {
    $infoString = "Some requirements were not met:`n- " + ($script:failureMessages -join "`n- ")
}

# The only output of this script is the final object.
return [PSCustomObject]@{
    result = $AllChecksPassed
    info   = $infoString
}
