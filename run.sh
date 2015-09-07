#!/bin/bash
set -u
set -o pipefail

export WARNINGS_THRESHOLD=${WERCKER_WARNINGS_THRESHOLD:-0}
export FILES_FOLDER=${WERCKER_FILES_FOLDER:-'_posts'}
export LANG_COUNTRY=${WERCKER_LANG_COUNTRY:-'en-GB'}
export LANG=${WERCKER_LANG:-'en'}
export EXIT=0

echo "Installing dependencies..."
# Installing Alex.
sudo npm install alex --global > /dev/null

# Installing Aspell
sudo apt-get update > /dev/null
sudo apt-get -y install aspell-"${LANG}" > /dev/null
echo "personal_ws-1.1 en 200" > ~/.aspell."${LANG}".pws
cat "${WERCKER_STEP_ROOT}/custom_words.txt" >> ~/.aspell."${LANG}".pws

# Installing LanguageTool
curl -O https://www.languagetool.org/download/LanguageTool-3.0.zip > /dev/null
unzip LanguageTool-3.0.zip > /dev/null
cat "${WERCKER_STEP_ROOT}/custom_words.txt" >> "LanguageTool-3.0/org/languagetool/resource/${LANG}/hunspell/spelling.txt"

# Looping over blog posts files.
echo "Language set to ${LANG_COUNTRY}"

pushd "${FILES_FOLDER}"
for file in $( ls ); do
  # Run alex
  echo "Running Alex over ${file}..."
  alex_output="$( alex ${file} )"
  echo "${alex_output}"
  warnings_alex=$( echo "${alex_output}" | grep warning | wc -l )
  echo "${file} has ${warnings_alex} Alex warnings."

  # Run Aspell
  echo "Running Aspell list over ${file}..."
  aspell_output="$( cat ${file} | aspell list --lang=${LANG_COUNTRY} )"
  echo "${aspell_output}"
  warnings_aspell=$( echo "${aspell_output}" | wc -l )
  echo "${file} has ${warnings_aspell} Aspell warnings."
  
  # Run LanguageTool
  echo "Running LanguageTool..."
  language_output="$( java -jar ../LanguageTool-3.0/languagetool-commandline.jar -l ${LANG_COUNTRY} ${file} )"
  echo "${language_output}"
  warnings_languagetool=$( echo "${language_output}" | grep Rule ID: | wc -l )
  echo "${file} has ${warnings_aspell} LanguageTool warnings."

  $total_warnings=$((total_warnings+warnings_aspell+warnings_languagetool))
done
popd

echo "The total number of warnings is ${total_warnings}. The threshold is ${WARNINGS_THRESHOLD}"
if [[ "${total_warnings}" -gt "${WARNINGS_THRESHOLD}" ]]; then
  EXIT=1
fi 

if [ "${EXIT}" -ne 0 ]; then
  exit 1
fi
