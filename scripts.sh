#!/bin/bash

# ==============================================================================
# Git Collaboration Challenge Script
# ==============================================================================
# This script automates a series of tasks designed to simulate a real-world
# Git collaborative workflow, from setting up a repository to handling
# advanced scenarios like releases, hotfixes, and merge conflicts.
#
# INSTRUCTIONS:
# 1. Save this file as git_collaboration_challenge.sh
# 2. Make it executable: chmod +x git_collaboration_challenge.sh
# 3. IMPORTANT: Edit the CONFIGURATION variables below.
# 4. Run the script: ./git_collaboration_challenge.sh
# ==============================================================================

# --- CONFIGURATION ---
# ⚠️ Replace these placeholder values with your own information!
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"
# Example: "https://github.com/your-username/your-repo-name.git"
REMOTE_URL="YOUR_GITHUB_REPOSITORY_URL_HERE"

# --- SCRIPT SETUP ---
# Exit immediately if a command exits with a non-zero status.
set -e

# Function to print section headers
print_header() {
    echo ""
    echo "=============================================================================="
    echo "➡️  $1"
    echo "=============================================================================="
}

# --- SCRIPT START ---
print_header "Starting Git Collaboration Challenge"

# Verify that a remote URL has been set
if [ "$REMOTE_URL" == "YOUR_GITHUB_REPOSITORY_URL_HERE" ]; then
    echo "❌ ERROR: Please edit the script and set your remote repository URL in the CONFIGURATION section."
    exit 1
fi

## Task 1: Setting Up Remote Repository Connection

print_header "Task 1: Setting Up Remote Repository Connection"

# Create and navigate to the project directory
cd ~
rm -rf github-collaboration-project # Clean up previous runs
mkdir github-collaboration-project
cd github-collaboration-project

# Initialize Git and configure user
git init -b main
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"
echo "✅ Git repository initialized and configured."

# Create initial project files
echo "# GitHub Collaboration Project" > README.md
echo "This project demonstrates various Git workflows for team collaboration." >> README.md

echo -e "# Ignore dependencies\nnode_modules/\n\n# Ignore environment files\n.env\n*.env\n\n# Ignore log files\n*.log\n" > .gitignore
echo "✅ README.md and .gitignore files created."

# Make the initial commit
git add README.md .gitignore
git commit -m "Initial commit: Add README and .gitignore"

# Add remote and push
git remote add origin $REMOTE_URL
git push -u origin main
echo "✅ Initial commit pushed to the remote repository."

# Verify connection and log commands
git remote -v
echo "Remote connection verified."

# Document the setup process
cat > remote-setup-log.txt << EOL
# Remote Setup Log

This file documents the commands used to set up the remote repository connection.

1.  **Initialize Repository:**
    \`git init -b main\`

2.  **Configure User:**
    \`git config user.name "$GIT_USER_NAME"\`
    \`git config user.email "$GIT_USER_EMAIL"\`

3.  **Add and Commit Initial Files:**
    \`git add README.md .gitignore\`
    \`git commit -m "Initial commit: Add README and .gitignore"\`

4.  **Add Remote Origin:**
    \`git remote add origin $REMOTE_URL\`

5.  **Push to Remote:**
    \`git push -u origin main\`

6.  **Verify Connection:**
    \`git remote -v\`
EOL
git add remote-setup-log.txt
git commit -m "docs: Document remote setup process"
git push

---
## Task 2: Collaborative Branching Workflow

print_header "Task 2: Collaborative Branching Workflow"

# Create and push the develop branch
git checkout -b develop
git push -u origin develop
echo "✅ 'develop' branch created and pushed."

# Create feature/user-authentication branch
git checkout -b feature/user-authentication
echo "def login(user, password): pass" > auth.py
echo "class User: pass" > user.py
echo "<h1>Login Page</h1>" > login.html
git add .
git commit -m "feat: Implement basic user authentication structure"
git push -u origin feature/user-authentication
echo "✅ 'feature/user-authentication' branch created and pushed."

# Create feature/data-processing branch
git checkout develop
git checkout -b feature/data-processing
echo "def process_data(data): pass" > processor.py
echo "{}" > data.json
echo "def helper_function(): pass" > utils.py
git add .
git commit -m "feat: Add initial data processing modules"
git push -u origin feature/data-processing
echo "✅ 'feature/data-processing' branch created and pushed."

# Merge feature/user-authentication into develop
git checkout develop
git merge --no-ff feature/user-authentication -m "Merge feature/user-authentication"
git push origin develop
echo "✅ 'feature/user-authentication' merged into 'develop'."

# Document the branching strategy
cat > branching-strategy.txt << EOL
# Branching Strategy

-   \`main\`: Contains production-ready code.
-   \`develop\`: Main development branch where features are integrated.
-   \`feature/*\`: Individual branches for new features (e.g., \`feature/user-authentication\`). They are branched from \`develop\` and merged back into it.
EOL
git add branching-strategy.txt
git commit -m "docs: Document branching strategy"
git push

---
## Task 3: Handling Merge Conflicts

print_header "Task 3: Simulating and Resolving Merge Conflicts"

# Create feature/config-updates branch
git checkout -b feature/config-updates develop
echo "# Configuration settings\nAPI_KEY='feature_branch_api_key'" > config.py
git add .
git commit -m "feat: Add config file with API key"
git push -u origin feature/config-updates
echo "✅ 'feature/config-updates' branch created with a config file."

# Create a conflicting change in develop
git checkout develop
echo "# Main configuration\nDATABASE_URL='develop_branch_db_url'" > config.py
git add .
git commit -m "feat: Add config file with database URL"
echo "✅ Conflicting config file created on 'develop' branch."

# Attempt merge to create a conflict (|| true prevents script exit)
echo "⏳ Attempting to merge, a conflict is expected..."
git merge feature/config-updates || true

# Resolve the conflict automatically
echo "✅ Conflict detected as expected. Now resolving..."
echo -e "# Main configuration\nAPI_KEY='feature_branch_api_key'\nDATABASE_URL='develop_branch_db_url'" > config.py
git add config.py
git commit -m "fix: Resolve merge conflict for config file"
echo "✅ Merge conflict resolved and committed."

# Push the resolved develop branch
git push origin develop

# Document the resolution process
cat > conflict-resolution-log.txt << EOL
# Conflict Resolution Log

A merge conflict occurred in \`config.py\` when merging \`feature/config-updates\` into \`develop\`.

-   **Conflict Cause:** Both branches added a \`config.py\` file with different content.
-   **Resolution:** The changes were manually combined to include both the \`API_KEY\` from the feature branch and the \`DATABASE_URL\` from the develop branch.
EOL
git add conflict-resolution-log.txt
git commit -m "docs: Log conflict resolution process"
git push

# Clean up merged branches
git branch -d feature/user-authentication
git branch -d feature/config-updates
git push origin --delete feature/user-authentication
git push origin --delete feature/config-updates
echo "✅ Merged branches cleaned up locally and remotely."

# Document cleanup
echo "Deleted local branches: feature/user-authentication, feature/config-updates. Deleted remote branches with 'git push origin --delete <branch_name>'." > branch-cleanup-log.txt
git add branch-cleanup-log.txt
git commit -m "docs: Log branch cleanup"
git push

---
## Task 4: Pull Requests and Code Review Simulation

print_header "Task 4: Simulating Pull Request Workflow"

# Create and push feature/documentation branch
git checkout -b feature/documentation develop
mkdir -p docs
echo "# API Documentation" > docs/API.md
echo "# Contribution Guidelines" > docs/CONTRIBUTING.md
echo "# Changelog" > docs/CHANGELOG.md
git add .
git commit -m "docs: Add initial project documentation structure"
echo "✅ 'feature/documentation' branch created with initial docs."

# Create PR simulation files
echo "This pull request introduces comprehensive documentation for the project, including API guides and contribution guidelines." > pull-request-description.txt
echo "- [ ] Is the documentation clear and concise?\n- [ ] Are there any typos or grammatical errors?" > code-review-checklist.txt

# Simulate addressing review feedback
echo "\n## v1.0.0 - Initial Release" >> docs/CHANGELOG.md
git add docs/CHANGELOG.md
git commit -m "docs: Update changelog based on review feedback"
git push -u origin feature/documentation
echo "✅ Simulated review feedback and pushed updates."

# Merge the branch
git checkout develop
git merge --no-ff feature/documentation -m "Merge branch 'feature/documentation'"
git push origin develop
echo "✅ Documentation branch merged into 'develop'."

# Document the PR workflow
cat > pr-workflow-guide.txt << EOL
# Pull Request (PR) Workflow Guide

1.  Create a feature branch from \`develop\`.
2.  Make commits and push the branch to the remote.
3.  Create a Pull Request on GitHub from your feature branch to \`develop\`.
4.  Team members review the code, leave comments, and use a checklist.
5.  Address feedback with additional commits on the feature branch.
6.  Once approved, merge the PR into \`develop\`.
7.  Delete the feature branch after merging.
EOL
git add .
git commit -m "docs: Add PR workflow guide and simulation files"
git push

---
## Task 5: Advanced Git Collaboration Techniques

print_header "Task 5: Advanced Git Techniques"

# Create a release branch and tag it
git checkout -b release/v1.0.0 develop
echo "1.0.0" > VERSION.txt
echo "# Release Notes v1.0.0\n\n- Added user authentication\n- Implemented data processing" > RELEASE_NOTES.md
git add .
git commit -m "chore(release): Prepare for release v1.0.0"
git tag -a v1.0.0 -m "Release version 1.0.0"
git push -u origin release/v1.0.0
git push origin v1.0.0
echo "✅ Release v1.0.0 created, tagged, and pushed."

# Create a hotfix
git checkout -b hotfix/critical-security-fix release/v1.0.0
echo "Applied critical security patch" > security.patch
git add .
git commit -m "fix: Apply critical security patch"

# Merge hotfix into develop and release branches
git checkout develop
git merge --no-ff hotfix/critical-security-fix -m "Merge hotfix/critical-security-fix"
git checkout release/v1.0.0
git merge --no-ff hotfix/critical-security-fix -m "Merge hotfix/critical-security-fix"

# Tag the hotfix
git tag -a v1.0.1 -m "Hotfix release v1.0.1 for critical security issue"
git push --all
git push --tags
echo "✅ Hotfix created, merged into 'develop' and 'release/v1.0.0', and tagged as v1.0.1."

# Demonstrate git stash
git checkout develop
echo "This is a temporary change that should not be committed yet." > temp-work.txt
git stash
echo "✅ Work stashed. Working directory is clean."
# Here you could switch branches, pull changes, etc.
git stash pop
echo "✅ Stash popped. Temporary work is restored."
rm temp-work.txt # Clean up

# Demonstrate git rebase
git checkout -b feature/rebase-demo develop
echo "Change 1" > rebase-demo.txt
git add . && git commit -m "feat: Add part 1 of rebase demo"
echo "Change 2" >> rebase-demo.txt
git add . && git commit -m "feat: Add part 2 of rebase demo"

# Make a change on develop to rebase onto
git checkout develop
echo "This commit moves develop's HEAD forward." > update.txt
git add . && git commit -m "feat: Update develop with new file"
git push

# Rebase the feature branch
git checkout feature/rebase-demo
git rebase develop
git push -u origin feature/rebase-demo --force-with-lease # Force push is needed after rebase
echo "✅ 'feature/rebase-demo' rebased onto 'develop' and pushed."

# Create the final comprehensive guide
cat > git-collaboration-guide.txt << EOL
# Comprehensive Git Collaboration Guide

## Remote Repository Workflows
-   **Origin:** The default name for the remote repository you cloned from.
-   **Fetch vs. Pull:** \`git fetch\` downloads changes without merging, while \`git pull\` fetches and merges.
-   **Pushing:** Use \`git push origin <branch_name>\` to share your changes.

## Branching Strategies
-   **GitFlow (simulated here):** Uses \`main\`, \`develop\`, \`feature/*\`, \`release/*\`, and \`hotfix/*\` branches for a structured workflow.
-   **GitHub Flow:** A simpler model where \`main\` is always deployable and feature branches are created from it.

## Merge vs. Rebase
-   **Merge:** Combines histories with a "merge commit". Preserves the exact history of branches. Good for shared branches like \`develop\`.
-   **Rebase:** Re-writes commit history by replaying commits on top of another branch. Creates a cleaner, linear history. Best used on private feature branches before merging to avoid issues for collaborators.

## Tag Management
-   **Lightweight Tags:** Simple pointers to a specific commit.
-   **Annotated Tags (used here):** Recommended for releases. They are stored as full objects in the Git database, containing the tagger's name, email, date, and a message.
-   **Commands:** \`git tag -a v1.0 -m "message"\`, \`git push origin --tags\`.

## Best Practices
-   Commit often with clear, descriptive messages.
-   Keep branches small and focused on a single feature or fix.
-   Pull changes from \`develop\` frequently into your feature branch to avoid large conflicts.
-   Use Pull Requests for code review before merging.
-   Clean up merged branches.
EOL
git add .
git commit -m "docs: Add final comprehensive collaboration guide"
git push

# --- SCRIPT FINISH ---
print_header "🎉 All tasks completed successfully!"
echo "Your local repository is in '~/github-collaboration-project'"
echo "All branches, tags, and files have been pushed to the remote repository."
