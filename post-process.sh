#!/bin/bash

VERSION=$(sed -n 's|.*"version":"\([^"]*\)".*|\1|p' "$FOLDER/version.json")

rm -rf "$TARGET_FOLDER"
mkdir "$TARGET_FOLDER"

# FOLDER=build/web, TARGET_FOLDER=dist
mv "$FOLDER" "$TARGET_FOLDER/$VERSION"

mv "$TARGET_FOLDER/$VERSION/index.html" "$TARGET_FOLDER"
cp "$TARGET_FOLDER/$VERSION/version.json" "$TARGET_FOLDER"

# On macOS, sed needs an explicit extension with -i
#sed -i.bak "s|<base href=\"/\" />|<base href=\"/$VERSION/\" />|g" "./$TARGET_FOLDER/index.html"
#rm "./$TARGET_FOLDER/index.html.bak"

cd ../fitness-vibe-nextjs/public
rm -Rf app
mkdir app
cp -r ../../fitness-vibe/dist/web/ ./app/
cd ..
git add .
git commit -m "Push new Flutter build."
git push
cd ../fitness-vibe
