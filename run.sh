#!/bin/bash
set -x
set -o pipefail

export FILES_FOLDER=${WERCKER_FILES_FOLDER:-'_posts'}
export MAIN_REPO=${WERCKER_MAIN_REPO:-'git@github.com:Capgemini/capgemini.github.io.git'}

# Retrieving main repo info.
git remote add upstream "${MAIN_REPO}"
git fetch upstream
if git diff upstream/master --name-only | grep "${FILES_FOLDER}/"; then

  # Install Alex.
  npm install alex --global

  # Looping over blog posts files.
  for file in $( git diff upstream/master --name-only | grep "${FILES_FOLDER}/" ); do
  	alex "${file}"
  done
else
  echo "No changes related to text files."
fi
git remote remove upstream
