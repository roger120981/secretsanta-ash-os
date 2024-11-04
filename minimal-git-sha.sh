#!/usr/bin/env bash

set -eu

git_sha=$(cat .git/HEAD | awk '{print ".git/"$2}' | xargs cat | head -c 8)

echo $git_sha
