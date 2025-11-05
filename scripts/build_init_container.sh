#!/bin/bash
set -e

echo "Building blog-generator init container for Minikube..."

# Get the script directory to find values.yaml
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/../helm/values.yaml"

# Get git commit hash for image tagging
GIT_HASH=$(git rev-parse --short HEAD)
IMAGE_NAME="blog-generator"
IMAGE_TAG="${GIT_HASH}"

echo "Image will be tagged as: ${IMAGE_NAME}:${IMAGE_TAG}"

# Point Docker CLI to Minikube's Docker daemon
echo "Configuring Docker to use Minikube's daemon..."
eval "$(minikube docker-env)"

# Build the image
echo "Building Docker image..."
cd "${SCRIPT_DIR}/../helm"
docker build -f docker/Dockerfile -t "${IMAGE_NAME}:${IMAGE_TAG}" ..

echo ""
echo "✓ Build complete!"

# Update values.yaml with the new tag
echo "Updating helm/values.yaml with tag: ${IMAGE_TAG}..."
sed -i.bak "s/tag: \".*\" # initContainer tag/tag: \"${IMAGE_TAG}\" # initContainer tag/" "${VALUES_FILE}" || \
sed -i.bak "/initContainer:/,/^[^ ]/ s/tag: \".*\"/tag: \"${IMAGE_TAG}\"/" "${VALUES_FILE}"
rm -f "${VALUES_FILE}.bak"

echo "✓ values.yaml updated!"
echo ""

# Show the diff
echo "Changes made to helm/values.yaml:"
cd "${SCRIPT_DIR}/.."
git diff helm/values.yaml

# Check if there are changes to commit
if git diff --quiet helm/values.yaml; then
    echo ""
    echo "No changes detected in values.yaml - tag was already ${IMAGE_TAG}"
    exit 0
fi

# Commit and push
echo ""
echo "Committing and pushing changes..."
git add helm/values.yaml
git commit -m "Update init container to ${IMAGE_TAG}"
git push origin main

echo ""
echo "✓ All done! Changes committed and pushed."
echo ""
echo "ArgoCD will automatically sync and deploy the new version."
