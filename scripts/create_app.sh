#!/bin/bash

set -euo pipefail

# Display usage information
usage() {
    echo "Usage: $0 <app-name> <git-repo> <repo-path>"
    echo ""
    echo "Arguments:"
    echo "  app-name   - Name of the ArgoCD application to create"
    echo "  git-repo   - Git repository URL"
    echo "  repo-path  - Path within the repository"
    exit 1
}

# Check if all arguments are provided
if [[ $# -ne 3 ]]; then
    echo "Error: Invalid number of arguments"
    usage
fi

APP_NAME="$1"
GIT_REPO="$2"
REPO_PATH="$3"

# Validate that argocd is available
if ! command -v argocd &> /dev/null; then
    echo "Error: argocd CLI is not installed or not in PATH"
    exit 1
fi

# Create the ArgoCD application
echo "Creating ArgoCD application: $APP_NAME"
argocd app create "$APP_NAME" \
    --repo "$GIT_REPO" \
    --path "$REPO_PATH" \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace default

echo "Application '$APP_NAME' created successfully"
