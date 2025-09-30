# check_challenge.ps1 (Version 3: Returns a PSCustomObject)
#
# A script to verify the completion of the Git Fundamentals Project challenge.
# It can be run from any directory and returns a structured object for automation.

# --- Script Parameters ---
param(
    [string]$ProjectPath = "$env:USERPROFILE\Desktop\activity\git-fundamentals-project"
)

# --- Script-Scoped Variables for Final Report ---
$script:failureMessages = [System.Collections.Generic.List[string]]::new()

# --- Helper Functions ---
function Check-Requirement {
    param(
        [Parameter(Mandatory=$true)]
        [bool]$Condition,
        [Parameter(Mandatory=$true)]
        [string]$SuccessMessage,
        [Parameter(Mandatory=$false)]
        [string]$FailureMessage = "Requirement not met."
    )
    if ($Condition) {
        Write-Host "  [✔] " -ForegroundColor Green -NoNewline; Write-Host $SuccessMessage
        return $true
    } else {
        Write-Host "  [✘] " -ForegroundColor Red -NoNewline; Write-Host $FailureMessage
        # Add the specific failure message to our list for the final report
        $script:failureMessages.Add($FailureMessage)
        return $false
    }
}

function Print-SectionHeader {
    param([string]$Title)
    Write-Host "`n" + ("-" * 60); Write-Host " Verifying: $Title"; Write-Host ("-" * 60)
}

function Test-FileNotEmpty {
    param([string]$FilePath)
    return (Test-Path $FilePath) -and ((Get-Item $FilePath).Length -gt 0)
}

# --- Main Script ---
# Suppress console output from commands and focus on our own feedback
$ProgressPreference = 'SilentlyContinue'

Clear-Host
Write-Host "============================================="
Write-Host " Git Fundamentals Project Verification Script"
Write-Host "=============================================" -NoNewline

# --- Pre-check: Ensure the project directory exists ---
if (-not (Test-Path $ProjectPath -PathType Container)) {
    # Immediately return a failure object if the main directory is missing
    return [PSCustomObject]@{
        result = $false
        info   = "CRITICAL: Project directory not found at the expected location: $ProjectPath"
    }
}
Write-Host "`n🔍 Checking project located at: $ProjectPath`n"

# --- Pre-check 2: Ensure it's a Git repository ---
if (-not (Test-Path (Join-Path $ProjectPath ".git"))) {
    return [PSCustomObject]@{
        result = $false
        info   = "CRITICAL: The directory is not a Git repository. Please run 'git init' inside it."
    }
}

$AllChecksPassed = $true # Master boolean for the final result
$MainBranchName = if ($(git -C $ProjectPath branch --list main)) { "main" } else { "master" }

# --- Task 1: Git Repository Setup and Configuration ---
Print-SectionHeader "Task 1: Git Repository Setup"
$task1_passed = $true
$task1_passed = (Check-Requirement (Test-Path (Join-Path $ProjectPath ".git") -PathType Container) "Git repository has been initialized (.git folder found).") -and $task1_passed
$userName = git -C $ProjectPath config user.name
$userEmail = git -C $ProjectPath config user.email
$task1_passed = (Check-Requirement ($userName -eq "TestUser") "Git username is correctly configured as 'TestUser'." "Git username is not 'TestUser'.") -and $task1_passed
$task1_passed = (Check-Requirement ($userEmail -eq "testuser@example.com") "Git email is correctly configured as 'testuser@example.com'." "Git email is not 'testuser@example.com'.") -and $task1_passed
$gitignorePath = Join-Path $ProjectPath ".gitignore"
if (Test-Path $gitignorePath) {
    $gitignoreContent = Get-Content $gitignorePath
    $task1_passed = (Check-Requirement ($gitignoreContent -match "\.tmp" -and $gitignoreContent -match "\.log" -and $gitignoreContent -match "\.DS_Store") ".gitignore file contains required patterns." ".gitignore file is missing required patterns.") -and $task1_passed
} else { $task1_passed = (Check-Requirement $false ".gitignore file exists." ".gitignore file is missing.") -and $task1_passed }
$task1_passed = (Check-Requirement (Test-Path (Join-Path $ProjectPath "README.md")) "README.md file exists." "README.md file is missing.") -and $task1_passed
$task1_passed = (Check-Requirement ((git -C $ProjectPath log).Length -gt 0) "At least one commit has been made." "No commits found in the repository.") -and $task1_passed
$task1_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-setup-log.txt")) "'git-setup-log.txt' exists and is not empty." "'git-setup-log.txt' is missing or empty.") -and $task1_passed
if (-not $task1_passed) { $AllChecksPassed = $false }

# --- Task 2: Working with Git States and Basic Commands ---
Print-SectionHeader "Task 2: Working with Git States"
$task2_passed = $true
$task2_passed = (Check-Requirement (Test-Path (Join-Path $ProjectPath "main.java")) "'main.java' exists." "'main.java' is missing.") -and $task2_passed
$task2_passed = (Check-Requirement (Test-Path (Join-Path $ProjectPath "utils.java")) "'utils.java' exists." "'utils.java' is missing.") -and $task2_passed
$task2_passed = (Check-Requirement (Test-Path (Join-Path $ProjectPath "config.json")) "'config.json' exists." "'config.json' is missing.") -and $task2_passed
$filesInRepo = git -C $ProjectPath ls-tree -r HEAD --name-only
$task2_passed = (Check-Requirement ($filesInRepo -contains "main.java" -and $filesInRepo -contains "utils.java" -and $filesInRepo -contains "config.json") "Java and JSON files have been committed." "One or more of main.java, utils.java, config.json have not been committed.") -and $task2_passed
$task2_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-states-explanation.txt")) "'git-states-explanation.txt' exists and is not empty." "'git-states-explanation.txt' is missing or empty.") -and $task2_passed
if (-not $task2_passed) { $AllChecksPassed = $false }

# --- Task 3: Git History and Log Management ---
Print-SectionHeader "Task 3: Git History"
$task3_passed = $true
$commitCount = (git -C $ProjectPath log --oneline).Count
$task3_passed = (Check-Requirement ($commitCount -ge 5) "At least 5 commits found (Found: $commitCount)." "Fewer than 5 commits found (Found: $commitCount).") -and $task3_passed
$task3_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "commit-history.txt")) "'commit-history.txt' exists and not empty." "'commit-history.txt' is missing or empty.") -and $task3_passed
$task3_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-log-analysis.txt")) "'git-log-analysis.txt' exists and not empty." "'git-log-analysis.txt' is missing or empty.") -and $task3_passed
if (-not $task3_passed) { $AllChecksPassed = $false }

# --- Task 4: Basic Branching and Repository Management ---
Print-SectionHeader "Task 4: Branching and Merging"
$task4_passed = $true
$branches = git -C $ProjectPath branch
$task4_passed = (Check-Requirement ($branches -match "feature-development") "Branch 'feature-development' exists." "Branch 'feature-development' was not found.") -and $task4_passed
$task4_passed = (Check-Requirement ($branches -match "bugfix") "Branch 'bugfix' exists." "Branch 'bugfix' was not found.") -and $task4_passed
$featureFileExists = (git -C $ProjectPath ls-tree -r "feature-development" --name-only) -contains "feature.java"
$task4_passed = (Check-Requirement $featureFileExists "'feature.java' committed on 'feature-development' branch." "'feature.java' was not found on the 'feature-development' branch.") -and $task4_passed
$mergeCommitsOnMain = git -C $ProjectPath log $MainBranchName --merges --oneline
$task4_passed = (Check-Requirement ($mergeCommitsOnMain -match "Merge branch 'bugfix'") "The 'bugfix' branch has been merged into '$MainBranchName'." "The 'bugfix' branch has not been merged into '$MainBranchName'.") -and $task4_passed
$task4_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "branching-workflow.txt")) "'branching-workflow.txt' exists and not empty." "'branching-workflow.txt' is missing or empty.") -and $task4_passed
$task4_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-commands-summary.txt")) "'git-commands-summary.txt' exists and not empty." "'git-commands-summary.txt' is missing or empty.") -and $task4_passed
if (-not $task4_passed) { $AllChecksPassed = $false }

# --- Task 5: Git Best Practices and Workflow ---
Print-SectionHeader "Task 5: Best Practices"
$task5_passed = $true
$task5_passed = (Check-Requirement ($(git -C $ProjectPath branch) -match "development") "Branch 'development' exists." "Branch 'development' was not found.") -and $task5_passed
$task5_passed = (Check-Requirement (Test-Path (Join-Path $ProjectPath "docs") -PathType Container) "'docs' folder exists." "The 'docs' folder is missing.") -and $task5_passed
$task5_passed = (Check-Requirement (Test-FileNotEmpty (Join-Path $ProjectPath "git-workflow-guide.txt")) "'git-workflow-guide.txt' exists and not empty." "'git-workflow-guide.txt' is missing or empty.") -and $task5_passed
$repoStatus = git -C $ProjectPath status --porcelain
$task5_passed = (Check-Requirement ([string]::IsNullOrEmpty($repoStatus)) "Final repository state is clean." "Repository has uncommitted changes.") -and $task5_passed
if (-not $task5_passed) { $AllChecksPassed = $false }

# --- Final Object Creation ---
$infoString = ""
if ($AllChecksPassed) {
    $infoString = "🎉 Congratulations! All checks passed. You have successfully completed the challenge. 🎉"
} else {
    # Join all collected failure messages into a single string with newlines
    $infoString = "⚠️ Some requirements were not met. Please review the following items:`n- " + ($script:failureMessages -join "`n- ")
}

Write-Host "`n" + ("=" * 60)
Write-Host " Verification Complete"
Write-Host ("=" * 60)

# Create and return the custom object. This will be the script's actual output.
return [PSCustomObject]@{
    result = $AllChecksPassed
    info   = $infoString
}
