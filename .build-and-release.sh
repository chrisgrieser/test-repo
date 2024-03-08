#!/bin/zsh
cd "$(git rev-parse --show-toplevel)" || return 1

# Prompt for next version number
currentVersion=$(plutil -extract version xml1 -o - info.plist | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')
echo "current version: $currentVersion"
echo -n "   next version: "
read -r nextVersion
echo "────────────────────────"

# GUARD
if [[ -z "$nextVersion" || "$nextVersion" == "$currentVersion" ]]; then
	print "\033[1;31mInvalid version number\033[0m"
	exit 1
fi

#───────────────────────────────────────────────────────────────────────────────

# update version in REPOS info.plist
plutil -replace version -string "$nextVersion" info.plist

#
# INFO specific to my setup:
# update version in LOCAL info.plist
localInfoPlist="$HOME/.config/Alfred.alfredpreferences/workflows/$(basename "$PWD")/info.plist"
if [[ -f "$localInfoPlist" ]]; then
	plutil -replace version -string "$nextVersion" "$localInfoPlist"
fi

#───────────────────────────────────────────────────────────────────────────────

git add "info.plist" &&
	git commit -m "release: $nextVersion" &&
	git pull && git push &&
	git tag "$nextVersion" && git push origin --tags # trigger the release action
