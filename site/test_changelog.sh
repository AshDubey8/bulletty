#!/bin/bash

cd "$(dirname "$0")"

echo "# Changelog" > docs/changelog.md
echo "" >> docs/changelog.md

# Get the most recent tag
LAST_TAG=$(git describe --tags --abbrev=0)
echo "Last tag: $LAST_TAG"

# Get commits since last tag
echo "## nightly $(date +%Y-%m-%d)" >> docs/changelog.md
echo "" >> docs/changelog.md
git log $LAST_TAG..HEAD --oneline | while read line; do
    echo "- $line" >> docs/changelog.md
done
