#! /usr/bin/env bash
#
# COPYRIGHT Ericsson 2022
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

set -ux -o pipefail;

ML_PIPELINE_PATH="$1"
ARGOWF_IMAGE_FULL_NAME_PREFIX="$2"
CHANGED_FILES_BOBVAR_FILE="$3"

# Absolute filepath to this script
case "$(uname -s)" in
Darwin*) SCRIPT=$(greadlink -f $0) ;;
*) SCRIPT=$(readlink -f $0) ;;
esac

# Location of parent dir
BASE_DIR=$(dirname $SCRIPT)
REPOROOT=$(dirname $(dirname $BASE_DIR))
PRODUCT_INFO_FILE="charts/eric-aiml-pipeline/eric-product-info.yaml"
FOSSA_CONFIG_DIR="$REPOROOT/config/fossa"
FRAGMENTS_DIR="$REPOROOT/config/fragments"
ML_PIPELINE_FOSSA_CONFIG_DIR="config/fossa"
ML_PIPELINE_FRAGMENTS_DIR="config/fragments"
COMMON_PROPERTIES_FILE="rulesets/common-properties.yaml"
BUILD_RULESET_FILE="rulesets/build.yaml"

# derive 
dockerRegistry=$(echo $ARGOWF_IMAGE_FULL_NAME_PREFIX | awk -F/ '{print $1}')  ## not used
argowfImageRepo=$(echo $ARGOWF_IMAGE_FULL_NAME_PREFIX | awk -F/ '{print $2}')
argowfImageNamePrefix=$(echo $ARGOWF_IMAGE_FULL_NAME_PREFIX | awk -F/ '{print $3}' | awk -F: '{print $1}')
argowfImageVersion=$(echo $ARGOWF_IMAGE_FULL_NAME_PREFIX | awk -F/ '{print $3}' | awk -F: '{print $2}')

imageIds=( "argocli" "argoexec" "workflow-controller" "init" )

filesToSync=()

for imageId in "${imageIds[@]}"
do 
    echo "Set ${argowfImageNamePrefix}-${imageId} docker repo to ${argowfImageRepo}"
    image=$argowfImageNamePrefix-${imageId} repoPath=$argowfImageRepo yq e -i '.images[env(image)].repoPath = env(repoPath)' "${ML_PIPELINE_PATH}/$PRODUCT_INFO_FILE"
    echo "Set ${argowfImageNamePrefix}-${imageId} docker image version to ${argowfImageVersion}"
    image=$argowfImageNamePrefix-${imageId} tag=$argowfImageVersion yq e -i '.images[env(image)].tag = env(tag)' "${ML_PIPELINE_PATH}/$PRODUCT_INFO_FILE"
done 

changedFiles=($PRODUCT_INFO_FILE)

# Add new line after license header. It is lost due to yq manipulation
sed -i '/^productName:.*/i \ ' "${ML_PIPELINE_PATH}/$PRODUCT_INFO_FILE"

# compare stdout-redirect version
BUILD_REPO_STDOUT_REDIRECT_VERSION=$(yq '.properties[]| to_entries | .[]| select(.key == "stdout-redirect-version").value' $BUILD_RULESET_FILE)
SERVICE_REPO_STDOUT_REDIRECT_VERSION=$(yq '.properties[]| to_entries | .[]| select(.key == "stdout-redirect-version").value' "${ML_PIPELINE_PATH}/$COMMON_PROPERTIES_FILE")

if [ "$BUILD_REPO_STDOUT_REDIRECT_VERSION" != "$SERVICE_REPO_STDOUT_REDIRECT_VERSION" ]; then
    echo "stdout-redirect-version is different in build repo and service repo"
    echo "stdout-redirect-version in build repo: $BUILD_REPO_STDOUT_REDIRECT_VERSION"
    echo "stdout-redirect-version in service repo: $SERVICE_REPO_STDOUT_REDIRECT_VERSION"
    echo "Update stdout-redirect-version in service repo"
    sed -i "s/stdout-redirect-version: $SERVICE_REPO_STDOUT_REDIRECT_VERSION/stdout-redirect-version: $BUILD_REPO_STDOUT_REDIRECT_VERSION/g" "${ML_PIPELINE_PATH}/$COMMON_PROPERTIES_FILE"
    changedFiles+=("$COMMON_PROPERTIES_FILE")
fi

filesToSync=(
    "config/fossa/dependencies.2pp.yaml"
    "config/fossa/dependencies.3pp.yaml"
    "config/fossa/dependencies.argowf.yaml"
    "config/fossa/dependencies.argoui.yaml"
    "config/fossa/foss.usage.3pp.yaml"
    "config/fossa/foss.usage.argowf.yaml"
    "config/fossa/foss.usage.argoui.yaml"
    "config/fossa/license-agreement-3pp.json"
    "config/fossa/license-agreement-argowf.json"
    "config/fossa/license-agreement-argoui.json"
    "config/fragments/license-agreement.json"
    "config/fossa/cots/mc.yaml"
)

createParentDir(){
    local fileName=$1
    local parentDir=$(dirname $fileName)
    if [ ! -d "$ML_PIPELINE_PATH/$parentDir" ]; then
        mkdir -p "$ML_PIPELINE_PATH/$parentDir"
    fi
}


for file in "${filesToSync[@]}"; do
    createParentDir $file
    sourceFile="$REPOROOT/$file"
    destinationFile="$ML_PIPELINE_PATH/$file"
    echo "Syncing file from $sourceFile to $destinationFile"
    
    echo "Check if there are changes in $file"
    if [ -f $destinationFile ]
    then
        diff $sourceFile $destinationFile
        diffStatus=$?
    else 
        diffStatus=1
    fi
    if [ $diffStatus -eq 0 ]; then
        echo "No changes in $file"
    else
        echo "Detected changes in $file"
        changedFiles+=("$file")
        echo "Copy $sourceFile to $destinationFile"
        cp $sourceFile $destinationFile
    fi
done

printf '%s\n' "${changedFiles[@]}" > $CHANGED_FILES_BOBVAR_FILE

