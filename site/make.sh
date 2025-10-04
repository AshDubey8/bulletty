# Generating rustdoc using `rustdoc-md`. It uses a nightly version or rust
RUSTC_BOOTSTRAP=1 RUSTDOCFLAGS="-Z unstable-options --output-format json" cargo doc --no-deps
rustdoc-md --path ../target/doc/bulletty.json --output docs/docs/bulletty.md
cat ./docs/docs/_reference.md > ./docs/docs/reference.md
echo "" >> ./docs/docs/reference.md
cat ./docs/docs/bulletty.md >> ./docs/docs/reference.md

# Generate index page using README.md
cat ./docs/_index.md > ./docs/index.md
tail -n +3 ../README.md >> ./docs/index.md

# Generate contributing page using CONTRIBUTING.md
cat ./docs/_contributing.md > ./docs/contributing.md
tail -n +3 ../CONTRIBUTING.md >> ./docs/contributing.md

# Generate changelog from git tags
OUTPUT="docs/changelog.md"
echo "---" > $OUTPUT
echo "title: Changelog" >> $OUTPUT
echo "---" >> $OUTPUT
echo "" >> $OUTPUT

TAGS=($(git tag -l "v*" --sort=-version:refname))

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

for i in "${!TAGS[@]}"; do
    TAG="${TAGS[$i]}"
    echo "## $TAG" >> $OUTPUT
    echo "" >> $OUTPUT
    
    NEXT_INDEX=$((i + 1))
    if [ $NEXT_INDEX -lt ${#TAGS[@]} ]; then
        PREV_TAG="${TAGS[$NEXT_INDEX]}"
        git log $PREV_TAG..$TAG --oneline | while read line; do
            echo "- $line" >> $OUTPUT
        done
    else
        git log $TAG --oneline | while read line; do
            echo "- $line" >> $OUTPUT
        done
    fi
    echo "" >> $OUTPUT
done

cp -R ../img ./docs/img
uv venv --clear
uv tool install mkdocs
uv pip install mkdocs-material
uv run mkdocs build
