#!/bin/bash
set -u
set -o pipefail

export FILES_FOLDER=${WERCKER_FILES_FOLDER:-'_posts'}
export LANG_COUNTRY=${WERCKER_LANG_COUNTRY:-'en-GB'}
export LANG=${WERCKER_LANG:-'en'}
export EXIT=0

if git diff origin/master --name-only | grep "${FILES_FOLDER}/"; then

  # Installing Alex.
  sudo npm install alex --global

  # Installing Aspell
  sudo apt-get update
  sudo apt-get -y install aspell-"${LANG}"
  echo "personal_ws-1.1 en 200" > ~/.aspell."${LANG}".pws
  cat "${WERCKER_STEP_ROOT}/custom_words.txt" >> ~/.aspell."${LANG}".pws

  # Installing LanguageTool
  curl -O https://www.languagetool.org/download/LanguageTool-3.0.zip
  unzip LanguageTool-3.0.zip
  cat "${WERCKER_STEP_ROOT}/custom_words.txt" >> "LanguageTool-3.0/org/languagetool/resource/${LANG}/hunspell/spelling.txt"

  # Looping over blog posts files.
  echo "Language set to ${LANG_COUNTRY}"
  for file in $( git diff upstream/master --name-only | grep "${FILES_FOLDER}/" ); do
  	echo "Running Alex over ${file}..."
        alex_output="$( alex ${file} )"
        echo "${alex_output}"
        if [[ "${alex_output}" =~ "warning"  ]]; then
          EXIT=1
        fi
 
        echo "Running Aspell list over ${file}..."
        aspell_output="$( cat ${file} | aspell list --lang=${LANG_COUNTRY} )"
        echo "${aspell_output}"
        if [ -n "${aspell_output}" ]; then
          EXIT=1
        fi
        
        echo "Running LanguageTool..."
        language_output="$( java -jar /home/vagrant/LanguageTool-3.0/languagetool-commandline.jar -l ${LANG_COUNTRY} ${file} )"
        echo "${language_output}"
        if [[ "${language_output}" =~ "Line" ]]; then
          EXIT=1
        fi 
 done
else
  echo "No changes related to text files."
fi

exit "${EXIT}"
