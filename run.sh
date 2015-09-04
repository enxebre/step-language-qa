#!/bin/bash
set -eux
set -o pipefail

export FILES_FOLDER=${WERCKER_FILES_FOLDER:-'_posts'}
export MAIN_REPO=${WERCKER_MAIN_REPO:-'git@github.com:Capgemini/capgemini.github.io.git'}

git add remote upstream "${MAIN_REPO}"
if git diff upstream/master --name-only | grep "${FILES_FOLDER}/"; then

  # Install Alex.
  npm install alex --global

  #looping over blog posts files.
  git diff upstream/master --name-only | grep "${FILES_FOLDER}/" | while read file; do alex "${file}"; done
else
  echo "No changes related to text files."
fi