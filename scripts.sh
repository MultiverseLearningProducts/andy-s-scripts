#!/bin/bash

# ==============================================================================
# Bash Script to Complete the Git Fundamentals Challenge (Corrected Version)
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper for colored output ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_NC='\033[0m' # No Color

echo -e "${COLOR_YELLOW}Starting the Git Fundamentals Challenge script...${COLOR_NC}"

# --- Task 1: Git Repository Setup and Configuration ---
echo -e "\n${COLOR_GREEN}--- Task 1: Git Repository Setup and Configuration ---${COLOR_NC}"
# Clean up previous run if it exists
rm -rf git-fundamentals-project
mkdir -p git-fundamentals-project
cd git-fundamentals-project

# Log all commands for this task into git-setup-log.txt
LOG_FILE="git-setup-log.txt"
> "$LOG_FILE" # Clear the log file if it exists

log_and_run() {
    echo "$ $@" >> "$LOG_FILE"
    "$@"
}

log_and_run git init
# Set the default branch name to main for consistency
log_and_run git config -g init.defaultBranch main
log_and_run git branch -M main

log_and_run git config user.name "TestUser"
log_and_run git config user.email "testuser@example.com"

# Create .gitignore
echo -e "*.tmp\n*.log\n.DS_Store" > .gitignore
echo 'echo -e "*.tmp\\n*.log\\n.DS_Store" > .gitignore' >> "$LOG_FILE"

# Create README.md
echo "# Git Fundamentals Project" > README.md
echo 'echo "# Git Fundamentals Project" > README.md' >> "$LOG_FILE"

log_and_run git add .
log_and_run git commit -m "Initial commit: Add README and .gitignore"
log_and_run git status
log_and_run git log --oneline

echo "Task 1 complete. Commands logged to $LOG_FILE."

# --- Task 2: Working with Git States and Basic Commands ---
echo -e "\n${COLOR_GREEN}--- Task 2: Working with Git States ---${COLOR_NC}"
echo "public class Main { public static void main(String[] args) { System.out.println(\"Hello\"); } }" > main.java
echo "public class Utils { public static void helper() {} }" > utils.java
echo "{ \"setting\": \"enabled\" }" > config.json
echo "Current status (3 untracked files):"
git status

git add main.java
echo "Status after staging main.java:"
git status

echo "// Adding a comment" >> main.java
echo "Diff between working directory and staging area for main.java:"
git diff main.java

echo "Diff between staging area and repository (shows staged version of main.java):"
git diff --cached

git add .
git commit -m "Feat: Add java source files and config"

cat <<EOF > git-states-explanation.txt
Git has three main states for your files:
1.  Working Directory: Your local files that you are currently editing.
2.  Staging Area (Index): A snapshot of files you've marked ('git add') to be included in your next commit.
3.  Repository (.git directory): The permanent history of all your committed snapshots.

'git status' shows the state of files. 'git diff' shows changes in the working directory not yet staged. 'git diff --cached' shows staged changes that are not yet committed.
EOF
echo "Task 2 complete. Wrote explanation to git-states-explanation.txt."

# --- Task 3: Git History and Log Management ---
echo -e "\n${COLOR_GREEN}--- Task 3: Git History and Log Management ---${COLOR_NC}"
# Make 3 more commits
echo "public class Utils { public static void helper() { /* updated */ } }" > utils.java
git commit -am "Refactor: Update Utils helper method"

echo "{ \"setting\": \"disabled\", \"mode\": \"safe\" }" > config.json
git commit -am "Config: Disable setting and add safe mode"

echo "Initial project setup for learning Git fundamentals." >> README.md
git commit -am "Docs: Update project description in README"

echo "Viewing condensed, graphical log:"
git log --graph --oneline

LATEST_HASH=$(git log --oneline -1 | cut -d' ' -f1)
echo "Showing details for a specific commit ($LATEST_HASH):"
git show "$LATEST_HASH"

git log > commit-history.txt

cat <<EOF > git-log-analysis.txt
Analysis of 'git log' commands:
- 'git log': Shows the complete commit history with author, date, and full message.
- 'git log --oneline': Condenses each commit to a single line showing the hash and title.
- 'git log --graph': Displays the branch and merge history as an ASCII graph.
- 'git show <hash>': Shows the metadata and content changes of a specific commit.
- 'git log --author="TestUser"': Filters the log to show only commits by a specific author.
EOF

echo "Task 3 complete. Saved log to commit-history.txt and analysis to git-log-analysis.txt."

# --- Task 4: Basic Branching and Repository Management ---
echo -e "\n${COLOR_GREEN}--- Task 4: Basic Branching and Repository Management ---${COLOR_NC}"
git branch feature-development
git switch feature-development

echo "public class Feature { public void newFeature() {} }" > feature.java
git add feature.java
git commit -m "Feat: Implement new feature"

git switch main
echo "Switched to main. 'feature.java' should not exist here:"
ls -la

git branch bugfix
git switch bugfix
echo "A small fix for a bug." >> README.md
git commit -am "Fix: Correct typo in README"

git switch main
# --- FIX #1: Use --no-ff to force a merge commit ---
git merge --no-ff bugfix

echo "Current branches (* indicates active branch):"
git branch

cat <<EOF > branching-workflow.txt
Branching allows for parallel development.
1. Create a branch ('git branch <name>') for a new feature or bugfix.
2. Switch to it ('git switch <name>').
3. Make and commit changes on this branch. This isolates your work from the main codebase.
4. When work is complete and tested, switch back to the main branch and merge the changes ('git merge <name>').
EOF

echo "Task 4 complete. Wrote explanation to branching-workflow.txt."

# --- Task 5: Git Best Practices and Workflow ---
echo -e "\n${COLOR_GREEN}--- Task 5: Git Best Practices and Workflow ---${COLOR_NC}"
git branch development
git switch development

mkdir docs
echo "Documentation for main.java" > docs/main.md
git add .
git commit -m "Feat: Add documentation structure"

echo "Documentation for utils.java" > docs/utils.md
git add .
git commit -m "a bad commit message"
git commit --amend -m "Docs: Add documentation for utils"

# Demonstrate reset
touch temp.log
git add temp.log
echo "Staged temp.log, now resetting..."
git reset HEAD temp.log
rm temp.log

# Demonstrate checkout
echo "Adding a mistake to README" >> README.md
git status
echo "Discarding mistake from README..."
git checkout -- README.md
git status

cat <<EOF > git-workflow-guide.txt
A comprehensive guide to Git workflows.

Best Practices for Commit Messages:
- Use imperative mood ("Add feature" not "Added feature").
- Separate subject from body with a blank line.
- Limit the subject line to 50 characters.

Branching Strategy:
- 'main' is always stable and deployable.
- 'development' is the integration branch for features.
- Feature branches ('feature/...') are for new work.
- Bugfix branches ('bugfix/...') are for urgent fixes.

Common Workflow (Git Flow):
1. Create a 'develop' branch from 'main'.
2. Create feature branches from 'develop'.
3. When a feature is complete, merge it back into 'develop'.
4. When 'develop' is stable, merge it into 'main' for a release.
EOF

# Create a final summary file from Task 4
cp branching-workflow.txt git-commands-summary.txt
echo -e "\nSummary of commands can be found by reviewing the script and log files." >> git-commands-summary.txt

# --- FIX #2: Add and commit the final documentation files ---
echo "Adding final documentation files to the repository..."
git add .
git commit -m "Docs: Add final workflow and summary documents"

# Final check
echo "Final repository status:"
git status
echo -e "\n${COLOR_YELLOW}All challenge tasks have been completed successfully!${COLOR_NC}"
