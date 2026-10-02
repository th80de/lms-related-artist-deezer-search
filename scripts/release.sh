#!/usr/bin/env sh
set -eu

version=$(tr -d '[:space:]' < VERSION)
plugin=RelatedArtistDeezerSearch
dist_dir=dist
archive="$dist_dir/$plugin-$version.zip"

rm -rf "$dist_dir"
mkdir -p "$dist_dir"

zip -q -r "$archive" Plugin.pm install.xml strings.txt README.md VERSION \
  -x '*.DS_Store'

sha1=$(shasum -a 1 "$archive" | awk '{print $1}')
printf '%s  %s\n' "$sha1" "$archive"
printf 'For a new version, update its URL and SHA-1 in repo.xml.\n'
