#!/bin/sh

set -u

REPO_NAME="${INPUT_REPOSITORY_NAME}"
AWS_REGION="${INPUT_AWS_REGION}"
CC_URL="https://git-codecommit.${AWS_REGION}.amazonaws.com/v1/repos/${REPO_NAME}"

set -x

# Check if the repository exists
aws codecommit get-repository --repository-name $REPO_NAME > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Repository $REPO_NAME already exists."
else
  echo "Repository $REPO_NAME does not exist. Creating now..."
  aws codecommit create-repository --repository-name $REPO_NAME
  if [ $? -eq 0 ]; then
    echo "Repository $REPO_NAME created successfully."
  else
    echo "Failed to create repository $REPO_NAME."
  fi
fi

set -e

git config --global credential.'https://git-codecommit.*.amazonaws.com'.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
git config --global --add safe.directory /github/workspace
git remote add sync ${CC_URL}
git push sync --mirror
