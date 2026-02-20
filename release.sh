#!/bin/bash
# Release script for kitty_protocol
# Usage: ./release.sh [patch|minor|major]

set -e

# Get current version from pubspec.yaml
get_version() {
    grep '^version:' pubspec.yaml | sed 's/version: //'
}

# Parse version components
parse_version() {
    local version=$1
    MAJOR=$(echo $version | cut -d. -f1)
    MINOR=$(echo $version | cut -d. -f2)
    PATCH=$(echo $version | cut -d. -f3)
}

# Bump version
bump_version() {
    local type=$1
    local current=$(get_version)
    parse_version "$current"

    case $type in
        patch)
            PATCH=$((PATCH + 1))
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        *)
            echo "Usage: $0 [patch|minor|major]"
            exit 1
            ;;
    esac

    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
    echo "Bumping version: $current → $NEW_VERSION"
}

# Check for uncommitted changes
check_clean() {
    if [[ -n $(git status --porcelain) ]]; then
        echo "Error: You have uncommitted changes. Commit or stash them first."
        git status
        exit 1
    fi
}

# Update version in pubspec.yaml
update_pubspec() {
    sed -i '' "s/version: $current_version/version: $NEW_VERSION/" pubspec.yaml
}

# Update CHANGELOG
update_changelog() {
    local date=$(date '+%Y-%m-%d')
    cat > /tmp/changelog_entry.md << EOF
## $NEW_VERSION

- (Add your changes here)

## $current_version
EOF
    # Insert after first line (## version)
    head -n 1 CHANGELOG.md > /tmp/changelog_new.md
    cat /tmp/changelog_entry.md >> /tmp/changelog_new.md
    tail -n +2 CHANGELOG.md >> /tmp/changelog_new.md
    mv /tmp/changelog_new.md CHANGELOG.md
}

# Main
case "${1:-patch}" in
    patch|minor|major)
        type=$1
        ;;
    *)
        echo "Usage: $0 [patch|minor|major]"
        exit 1
esac

echo "=== Kitty Protocol Release Script ==="

check_clean
current_version=$(get_version)
bump_version $type

# Update files
update_pubspec
update_changelog

# Commit and tag
echo "Committing changes..."
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to $NEW_VERSION"
git tag "v$NEW_VERSION"

echo ""
echo "=== Ready to push ==="
echo "Run: git push && git push origin v$NEW_VERSION"
echo ""
echo "This will trigger CI/CD which will:"
echo "  1. Run tests & analysis"
echo "  2. Publish to pub.dev automatically"
