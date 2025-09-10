#!/bin/bash

./bump_version.sh patch
PUBSPEC_FILE="./pubspec.yaml"
current_version_full=$(yq e '.version' "$PUBSPEC_FILE")
flutter build web --base-href="/app/$current_version_full/" --release
export FOLDER=build/web
export TARGET_FOLDER=dist/web
./post-process.sh
