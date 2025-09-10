#!/bin/bash

# Script to update version in pubspec.yaml
# Usage: ./bump_version.sh [major|minor|patch|build]
# Default is 'patch' if no argument is provided.

PUBSPEC_FILE="./pubspec.yaml"
BUMP_TYPE=${1:-patch} # Default to 'patch' if no argument given

if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Error: $PUBSPEC_FILE not found."
    exit 1
fi

# Ensure yq is installed (mikefarah/yq)
if ! command -v yq &> /dev/null; then
    echo "Error: yq (mikefarah/yq) is not installed. Please install it first."
    echo "See: https://github.com/mikefarah/yq#install"
    exit 1
fi

echo "Reading current version from $PUBSPEC_FILE..."
current_version_full=$(yq e '.version' "$PUBSPEC_FILE")
if [ -z "$current_version_full" ]; then
    echo "Error: Could not read version from $PUBSPEC_FILE."
    exit 1
fi
echo "Current version: $current_version_full"

# Separate semantic version (e.g., 1.2.3) from build metadata (e.g., +4)
sem_ver_part=$(echo "$current_version_full" | awk -F'+' '{print $1}')
build_meta_part=$(echo "$current_version_full" | awk -F'+' '{if (NF>1) print $2; else print ""}')

# Split semantic version into major, minor, patch
IFS='.' read -r major minor patch <<< "$sem_ver_part"

case "$BUMP_TYPE" in
    major)
        major=$((major + 1))
        minor=0
        patch=0
        # Optionally, you might want to reset build_meta_part here, e.g., build_meta_part="1" or ""
        ;;
    minor)
        minor=$((minor + 1))
        patch=0
        # Optionally, reset build_meta_part
        ;;
    patch)
        patch=$((patch + 1))
        # Optionally, reset build_meta_part
        ;;
    build)
        if [ -z "$build_meta_part" ]; then
            build_meta_part=1 # Start from 1 if no build number exists
        else
            build_meta_part=$((build_meta_part + 1))
        fi
        ;;
    *)
        echo "Invalid bump type: $BUMP_TYPE. Use 'major', 'minor', 'patch', or 'build'."
        exit 1
        ;;
esac

new_sem_ver_part="$major.$minor.$patch"

if [ -n "$build_meta_part" ]; then
    new_version_full="$new_sem_ver_part+$build_meta_part"
else
    new_version_full="$new_sem_ver_part"
fi

echo "Updating version in $PUBSPEC_FILE to $new_version_full..."
yq e ".version = \"$new_version_full\"" -i "$PUBSPEC_FILE"

echo "Version updated successfully to $new_version_full."
echo "Changes made to $PUBSPEC_FILE:"
git diff --no-index -- "$PUBSPEC_FILE.bak" "$PUBSPEC_FILE" 2>/dev/null || diff -u "$PUBSPEC_FILE.bak" "$PUBSPEC_FILE"
rm -f "$PUBSPEC_FILE.bak" # yq -i creates a .bak file on some systems/versions
