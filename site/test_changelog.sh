#!/bin/bash

cd "$(dirname "$0")"

OUTPUT="docs/changelog.md"

# Start the file
echo "---" > $OUTPUT
echo "title: Changelog" >> $OUTPUT
echo "---" >> $OUTPUT
echo "" >> $OUTPUT

# Get all tags sorted
TAGS=($(git tag -l "v*" --sort=-version:refname))

# Check if there are unreleased commits
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -n "$LAST_TAG" ]; then
    UNRELEASED=$(git log $LAST_TAG..HEAD --oneline)
    if [ -n "$UNRELEASED" ]; then
        echo "## nightly $(date +%Y-%m-%d)" >> $OUTPUT
        echo "" >> $OUTPUT
        git log $LAST_TAG..HEAD --oneline | while read line; do
            echo "- $line" >> $OUTPUT
        done
        echo "" >> $OUTPUT
    fi
fi

# Loop through all tags
for i in "${!TAGS[@]}"; do
    TAG="${TAGS[$i]}"
    echo "## $TAG" >> $OUTPUT
    echo "" >> $OUTPUT
    
    # Get the previous tag
    NEXT_INDEX=$((i + 1))
    if [ $NEXT_INDEX -lt ${#TAGS[@]} ]; then
        PREV_TAG="${TAGS[$NEXT_INDEX]}"
        git log $PREV_TAG..$TAG --oneline | while read line; do
            echo "- $line" >> $OUTPUT
        done
    else
        # First tag, get all commits up to it
        git log $TAG --oneline | while read line; do
            echo "- $line" >> $OUTPUT
        done
    fi
    echo "" >> $OUTPUT
done
