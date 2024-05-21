#!/bin/bash

# Check if required environment variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables must be set."
  exit 1
fi

# Get secret name and namespace from arguments (optional)
SECRET_NAME=${1:-aws-creds}       # Default to 'aws-creds' if not provided
NAMESPACE=${2:-crossplane-system}  # Default to 'crossplane-system'

# Check if secret exists
if ! kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" > /dev/null; then
  echo "Error: Secret '$SECRET_NAME' not found in namespace '$NAMESPACE'."
  exit 1
fi

# Update the secret with new credentials
kubectl patch secret "$SECRET_NAME" -n "$NAMESPACE" --type='json' -p='[{"op": "replace", "path": "/data/accessKeyId", "value": "'$(echo -n $AWS_ACCESS_KEY_ID | base64)'"}]'
kubectl patch secret "$SECRET_NAME" -n "$NAMESPACE" --type='json' -p='[{"op": "replace", "path": "/data/secretAccessKey", "value": "'$(echo -n $AWS_SECRET_ACCESS_KEY | base64)'"}]'

echo "Successfully updated AWS credentials in secret '$SECRET_NAME'."

